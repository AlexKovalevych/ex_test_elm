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
import Auth.Models exposing (CurrentUser)
import Socket.Messages as SocketM
import Storage.LocalStorage exposing (..)
import Phoenix.Socket
import Auth.Messages as AuthM
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
        redirectToLogin _ = ShowLogin
        initSocket token = token
            |> AuthM.SetToken
            |> AuthMsg
        cmd = Task.perform redirectToLogin initSocket (get("jwtToken"))
    in
        ( initialModel route location, cmd )

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
    Sub.batch ([
        Sub.map SocketMsg (Phoenix.Socket.listen model.socket.phxSocket SocketM.PhoenixMsg),
        Sub.map AuthMsg (loggedUser AuthM.LoadCurrentUser)
    ])

port loggedUser : (CurrentUser -> msg) -> Sub msg
