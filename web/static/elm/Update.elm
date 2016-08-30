module Update exposing (..)

import Debug
import Navigation
import Hop exposing (makeUrl)
import Hop.Types
import Models exposing (..)
import Routing exposing(..)
import Messages exposing (..)
import Phoenix.Socket


navigationCmd : String -> Cmd a
navigationCmd path =
    Navigation.newUrl (makeUrl config path)


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
