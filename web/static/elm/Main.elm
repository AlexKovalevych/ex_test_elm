port module Main exposing (..)

import Debug
import Navigation
import Hop exposing (matchUrl)
import Hop.Types exposing (Location)
import Routing exposing(..)
import Models exposing (..)
import View
import Update
import Material
import Messages exposing (..)
import Auth.Models exposing (CurrentUser)
import Socket.Messages as SocketMessages
import LocalStorage exposing (..)
import Phoenix.Socket
import Auth.Messages as AuthMessages
import Task
import Material.Layout as Layout
import Time exposing (Time, every, second)

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
        redirectToLogin _ = NavigateTo <|Just LoginRoute
        setToken token = token
            |> AuthMessages.SetToken
            |> AuthMsg
        setTokenCmd = Task.perform redirectToLogin setToken <| get "jwtToken"
        model = initialModel route location
    in
        model ! [ setTokenCmd, Layout.sub0 Mdl ]

main : Program Never
main =
    Navigation.program urlParser
        { init = init
        , view = View.view
        , update = Update.update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch ([
        Sub.map SocketMsg (Phoenix.Socket.listen model.socket.phxSocket SocketMessages.PhoenixMsg),
        Sub.map AuthMsg (loggedUser AuthMessages.LoadCurrentUser),
        Layout.subs Mdl model.mdl,
        Sub.map AuthMsg (every second AuthMessages.Tick),
        Material.subscriptions Mdl model
    ])

port loggedUser : (CurrentUser -> msg) -> Sub msg
