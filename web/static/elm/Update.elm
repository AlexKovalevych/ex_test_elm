module Update exposing (..)

import Debug
import Navigation
import Hop exposing (makeUrl)
import Models exposing (..)
import Routing exposing(..)
import Messages exposing (..)
import Socket.Messages as SocketMessages
import Socket.Update
import LocalStorage exposing (..)
import Auth.Update
import Auth.Messages as AuthMessages
import Auth.Models as AuthModels
import Material
import Task
import Auth.Models exposing (User(Guest, LoggedUser))
import Material.Snackbar as Snackbar
import Json.Decode as JD
import Json.Encode as JE
import Xhr exposing (post)
import Material.Helpers exposing (map1st, map2nd)
import Translation exposing (..)
import Phoenix.Push
import Dict
import Phoenix.Socket
import Update.Snackbar as UpdateSnackbar
import Translation exposing (translate)

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case Debug.log "message: " message of
        Mdl msg ->
            Material.update msg model

        Snackbar msg ->
            let
                ( snackbar, cmd ) = Snackbar.update msg model.snackbar
            in
                { model | snackbar = snackbar } ! [ Cmd.map Snackbar cmd ]

        AddToast msg ->
            let
                translatedMsg = translate model.locale msg
            in
                UpdateSnackbar.addToast translatedMsg model

        SetLocale locale ->
            let
                payload = (JE.string <| toString locale)
                push = Phoenix.Push.init "locale" (getFullChannelName "users" model)
                    |> Phoenix.Push.withPayload payload
                (phxSocket, phxCmd) = Phoenix.Socket.push push model.socket.phxSocket
                socketMsg = model.socket
                socket = { socketMsg | phxSocket = phxSocket }
            in
                { model | socket = socket, locale = locale } ! [ Cmd.map SocketMsg (Cmd.map SocketMessages.PhoenixMsg phxCmd) ]

        AuthMsg subMsg ->
            let
                ( updatedModel, cmd ) =
                    Auth.Update.update subMsg model.auth
            in
                { model | auth = updatedModel } ! [ Cmd.map authTranslator cmd ]

        SocketMsg subMsg ->
            let
                ( updatedModel, cmd ) =
                    Socket.Update.update subMsg model.socket
            in
                { model | socket = updatedModel } ! [ Cmd.map socketTranslator cmd ]

        ShowDashboard ->
            let
                path =
                    reverse DashboardRoute
            in
                model ! [ navigationCmd path ]

        ShowLogin ->
            let
                path =
                    reverse LoginRoute
            in
                model ! [ navigationCmd path ]

        NoOp ->
            model ! []

--Translators
authTranslator : Auth.Update.Translator Msg
authTranslator =
    Auth.Update.translator
    { onInternalMessage = AuthMsg
    , onSocketInit = SocketMsg << SocketMessages.InitSocket
    , onSocketRemove = SocketMsg SocketMessages.RemoveSocket
    , onJoinChannel = SocketMsg << SocketMessages.JoinChannel
    , onAddToast = AddToast
    , onShowLogin = ShowLogin
    }

socketTranslator : Socket.Update.Translator Msg
socketTranslator =
    Socket.Update.translator { onInternalMessage = SocketMsg, onSetLocale = SetLocale }

navigationCmd : String -> Cmd a
navigationCmd path =
    Navigation.newUrl (makeUrl config path)

getFullChannelName : String -> Model -> String
getFullChannelName name model =
    let channel =
        Dict.get "users" model.socket.channels
    in
        case channel of
            Nothing -> ""
            Just fullName -> fullName

setLocale : (Model, Cmd Msg) -> (Model, Cmd Msg)
setLocale (model, cmd) =
    case model.auth.user of
        Guest -> (model, cmd)
        LoggedUser user -> case user.locale of
            "Russian" -> { model | locale = Russian } ! [cmd]
            _ -> { model | locale = English } ! [cmd]
