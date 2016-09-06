module Socket.Update exposing (update)

import Debug
import Socket.Models exposing (..)
import Socket.Messages exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Native.Location

initPhxSocket : String -> Phoenix.Socket.Socket Msg
initPhxSocket server =
    Phoenix.Socket.init server
    |> Phoenix.Socket.withDebug

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
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
                _ = Debug.log "joined channel: " phxCmd
            in
                ({ model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        LeaveChannel name ->
            let
                (phxSocket, phxCmd) = Phoenix.Socket.leave name model.phxSocket
                _ = Debug.log "leave channel: " phxCmd
            in
                ({ model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )
