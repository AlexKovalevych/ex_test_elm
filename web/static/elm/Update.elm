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
import Socket.Update
import Auth.Update

navigationCmd : String -> Cmd a
navigationCmd path =
    Navigation.newUrl (makeUrl config path)

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case Debug.log "main message" message of
        AuthMsg subMsg ->
            let
                ( updatedAuth, cmd ) =
                    Auth.Update.update subMsg model.auth
            in
                ( { model | auth = updatedAuth }, Cmd.map AuthMsg cmd )

        SocketMsg subMsg ->
            (model, Cmd.none)
            --let
            --    ( updatedSocket, cmd ) =
            --        Socket.Update.update subMsg model.socket
            --in
            --    ( { model | socket = updatedSocket }, Cmd.map SocketMsg cmd )

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

        NoOp ->
            model ! []
