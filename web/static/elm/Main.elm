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



--cobalamin [10:31 PM]
--@a_kovalevych You want `Task`s to hand back `Msg`s, not model values. You should instead define `Msg`s to handle both – something like `RouteUpdated` and `InitSocket`

--[10:31]
--then figure out how to create `Msg`s from your `Task`, see `Task.perform`

--[10:31]

--and then handle those cases in `update`, very similar to what you're trying to put in `init` here



init : ( Route, Location ) -> ( Model, Cmd Msg )
init ( route, location ) =
    let
        cmd = Task.perform (\_ -> ShowLogin) InitSocket (get("jwtToken"))
    in
        ({location = location
        , route = route
        , auth = EmptyAuth
        , phxSocket = Phoenix.Socket.init ""}
        , cmd)

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
