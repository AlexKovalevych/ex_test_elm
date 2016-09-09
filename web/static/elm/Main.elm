port module Main exposing (..)

import Auth.Messages as AuthMessages
import Auth.Models exposing (CurrentUser)
import Debug
import Hop
import Hop.Types exposing (Address)
import Navigation
import LocalStorage exposing (..)
import Material
import Material.Layout as Layout
import Messages exposing (..)
import Models exposing (..)
import Phoenix.Socket
import Routing
import Socket.Messages as SocketMessages
import Task
import Time exposing (Time, every, second)
import Update
import View
import UrlParser

urlParser : Navigation.Parser ( Routing.Route, Address )
urlParser =
    let
        parse path =
            path
                |> UrlParser.parse identity Routing.routes
                |> Result.withDefault Routing.NotFoundRoute

        matcher =
            Hop.makeResolver Routing.config parse
    in
        Navigation.makeParser (.href >> matcher)

urlUpdate : ( Routing.Route, Address ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( route, address ) model =
    let
        _ =
            Debug.log "urlUpdate address" address
    in
        ( { model | route = route, address = address }, Cmd.none )

init : ( Routing.Route, Address ) -> ( Model, Cmd Msg )
init ( route, address ) =
    let
        redirectToLogin _ = NavigateTo Routing.LoginRoute
        setToken token = token
            |> AuthMessages.SetToken
            |> AuthMsg
        setTokenCmd = Task.perform redirectToLogin setToken <| get "jwtToken"
        model = initialModel route address
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
