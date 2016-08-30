port module Main exposing (..)

import Debug
import Navigation
import Hop exposing (matchUrl)
import Hop.Types exposing (Location)
import Routing exposing(..)
import Models exposing (..)
import View exposing (..)
import Update exposing (..)
import Messages exposing (..)
import Storage.LocalStorage exposing (..)
import Phoenix.Socket
import Task


urlParser : Navigation.Parser ( Route, Location )
urlParser =
    Navigation.makeParser (.href >> matchUrl config)


urlUpdate : ( Route, Location ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( route, location ) model =
    let
        _ =
            Debug.log "urlUpdate location" location
    in
        ( { model | route = route, location = location }, Cmd.none )


init : ( Route, Location ) -> ( Model, Cmd Msg )
init ( route, location ) =
    case getMaybe("jwtToken") of
        Nothing -> ( { phxSocket = Phoenix.Socket.Socket NoOp, auth = EmptyAuth, route = LoginRoute, location = location}, Cmd.none )
        Just token ->
            Phoenix.Socket.init "/socket?token=" ++ token
            ( {auth = EmptyAuth, route = LoginRoute, location = location}, Cmd.none )

main : Program Never
main =
    Navigation.program urlParser
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
