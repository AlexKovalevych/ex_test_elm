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
    let
        model = {location = location, route = route, auth = EmptyAuth, phxSocket = Phoenix.Socket.init ""}
    in
        case getMaybe("jwtToken") of
            Task _ Nothing ->
                ( { model | route = LoginRoute}, Cmd.none )
            Task _ (Just token) ->
                let socket = Phoenix.Socket.init ("/socket?token=" ++ token)
                in ( { model | phxSocket = socket, auth = EmptyAuth}, Cmd.none )

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
