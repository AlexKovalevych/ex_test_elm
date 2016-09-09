module Update exposing (..)

import Debug
import Navigation
import Hop
--import Hop exposing (makeUrl)
import Models exposing (..)
import Routing exposing (..)
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
import Translation exposing (translate)
import Update.Snackbar as UpdateSnackbar
import Update.Never exposing (never)

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

        NavigateTo route ->
            let
                path = Routing.reverse route
                command =
                    Hop.outputFromPath Routing.config path |> Navigation.newUrl
            in
                model !
                [ Task.perform never (\_ -> SetMenu <| getMenu route) (Task.succeed True)
                , command
                ]

        SetMenu menu ->
            { model | menu = menu } ! []

        SelectTab k ->
            case model.menu of
                Nothing -> model ! []
                Just menu ->
                    let
                        location = getRouteByTabIndex menu k
                    in
                        case location of
                            Nothing -> model ! []
                            Just route -> model ! [ Navigation.newUrl (reverse route) ]

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
    , onShowLogin = NavigateTo LoginRoute
    }

socketTranslator : Socket.Update.Translator Msg
socketTranslator =
    Socket.Update.translator
    { onInternalMessage = SocketMsg
    , onSetLocale = SetLocale
    , onUpdateCurrentUser = AuthMsg << AuthMessages.UpdateCurrentUser
    }

setLocale : (Model, Cmd Msg) -> (Model, Cmd Msg)
setLocale (model, cmd) =
    case model.auth.user of
        Guest -> (model, cmd)
        LoggedUser user -> case user.locale of
            "Russian" -> { model | locale = Russian } ! [cmd]
            _ -> { model | locale = English } ! [cmd]
