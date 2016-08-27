module Update exposing (..)

import Debug
import Navigation
import Hop exposing (makeUrl)
import Hop.Types
import Models exposing (..)
import Routing exposing(..)
import Messages exposing (..)


navigationCmd : String -> Cmd a
navigationCmd path =
    Navigation.newUrl (makeUrl config path)


update : Msg -> AppModel -> ( AppModel, Cmd Msg )
update message model =
    case Debug.log "message" message of
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
