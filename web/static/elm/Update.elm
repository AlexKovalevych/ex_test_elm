module Update exposing (..)

import Auth.Update
import Auth.Messages as AuthMessages
import Auth.Models exposing (User(Guest, LoggedUser))
import Dashboard.Update
import Dashboard.Messages as DashboardMessages
import Debug
import Dict
import Hop
import Json.Decode as JD
import Json.Encode as JE
import LocalStorage exposing (..)
import Material
import Material.Snackbar as Snackbar
import Material.Tooltip as Tooltip
import Messages exposing (..)
import Models exposing (..)
import Navigation
import Phoenix.Push
import Phoenix.Socket
import Routing exposing (..)
import Socket.Messages as SocketMessages
import Socket.Update
import Task
import Translation exposing (..)
import Update.Snackbar as UpdateSnackbar
import Update.Never exposing (never)

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
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

        TooltipMsg msg ->
            let
                updated = fst <| (Tooltip.update msg model.tooltip)
            in
                { model | tooltip = updated } ! []

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

        DashboardMsg subMsg ->
            let
                ( updatedModel, cmd ) =
                    Dashboard.Update.update subMsg model.dashboard
            in
                { model | dashboard = updatedModel } ! [ Cmd.map dashboardTranslator cmd ]

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
    , onShowDashboard = NavigateTo DashboardRoute
    }

socketTranslator : Socket.Update.Translator Msg
socketTranslator =
    Socket.Update.translator
    { onInternalMessage = SocketMsg
    , onSetLocale = SetLocale
    , onUpdateCurrentUser = AuthMsg << AuthMessages.UpdateCurrentUser
    , onUpdateDashboardData = DashboardMsg << DashboardMessages.LoadDashboardData
    }

dashboardTranslator : Dashboard.Update.Translator Msg
dashboardTranslator =
    Dashboard.Update.translator
    { onInternalMessage = DashboardMsg
    , onUpdateDashboardData = SocketMsg << SocketMessages.PushMessage
    , onSetDashboardSort = SocketMsg << SocketMessages.PushMessage
    , onSetDashboardCurrentPeriod = SocketMsg << SocketMessages.PushMessage
    , onSetDashboardComparisongPeriod = SocketMsg << SocketMessages.PushMessage
    , onSetDashboardProjectsType = SocketMsg << SocketMessages.PushMessage
    }

setLocale : (Model, Cmd Msg) -> (Model, Cmd Msg)
setLocale (model, cmd) =
    case model.auth.user of
        Guest -> (model, cmd)
        LoggedUser user -> case user.locale of
            "Russian" -> { model | locale = Russian } ! [cmd]
            _ -> { model | locale = English } ! [cmd]
