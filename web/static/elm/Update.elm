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

        SetLocale locale ->
            let
                payload = JE.string <| toString <| locale
                success = SocketMessages.DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = SocketMessages.PushModel "locale" "users" payload success error
                ( updatedModel, cmd ) = Socket.Update.update (SocketMessages.PushMessage pushModel) model.socket
            in
                { model | socket = updatedModel } ! [ Cmd.map socketTranslator cmd ]

        UpdateLocale locale ->
            let
                newLocale = case locale of
                    "Russian" -> Russian
                    _ -> English
            in
                { model | locale = newLocale } ! []

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
    , onSubscribeToUsersChannel = SocketMsg << SocketMessages.SubscribeToUsersChannel
    , onSubscribeToAdminsChannel = SocketMsg << SocketMessages.SubscribeToAdminsChannel
    , onAddToast = AddToast
    , onUpdateLocale = UpdateLocale
    , onShowLogin = ShowLogin
    }

socketTranslator : Socket.Update.Translator Msg
socketTranslator =
    Socket.Update.translator
    { onInternalMessage = SocketMsg
    , onSetLocale = SetLocale
    , onUpdateCurrentUser = AuthMsg << AuthMessages.UpdateCurrentUser
    }

navigationCmd : String -> Cmd a
navigationCmd path =
    Navigation.newUrl (makeUrl config path)

setLocale : (Model, Cmd Msg) -> (Model, Cmd Msg)
setLocale (model, cmd) =
    case model.auth.user of
        Guest -> (model, cmd)
        LoggedUser user -> case user.locale of
            "Russian" -> { model | locale = Russian } ! [cmd]
            _ -> { model | locale = English } ! [cmd]
