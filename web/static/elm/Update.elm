module Update exposing (..)

import Debug
import Navigation
import Hop exposing (makeUrl)
import Hop.Types
import Models exposing (..)
import Routing exposing(..)
import Messages exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Native.Location

navigationCmd : String -> Cmd a
navigationCmd path =
    Navigation.newUrl (makeUrl config path)


initPhxSocket : String -> Phoenix.Socket.Socket Msg
initPhxSocket server =
    Phoenix.Socket.init server
    |> Phoenix.Socket.withDebug


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case Debug.log "message" message of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        InitSocket token ->
            let
                location = Native.Location.getLocation ()
                socket = initPhxSocket ("ws://" ++ location.host ++ "/socket/websocket?token=" ++ token)
            in
                ( { model | phxSocket = socket }
                , Cmd.none
                )

        JoinChannel name ->
            let
                channel = Phoenix.Channel.init name
                (phxSocket, phxCmd) = Phoenix.Socket.join channel model.phxSocket
            in
                ({ model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        ShowDashboard ->
            let
                path =
                    reverse DashboardRoute
            in
                ( model, navigationCmd path )

        ShowLogin ->
            let
                path =
                    reverse LoginRoute
            in
                ( model, navigationCmd path )
