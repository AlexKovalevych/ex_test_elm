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
import Http exposing (fromJson, empty)
import Material.Helpers exposing (map1st, map2nd)
import Translation exposing (..)
--import Socket.Messages exposing(PhoenixMsg)
import Phoenix.Push
import Dict
import Phoenix.Socket

navigationCmd : String -> Cmd a
navigationCmd path =
    Navigation.newUrl (makeUrl config path)

mergeModel : Model -> (AuthModels.Model, Cmd AuthMessages.Msg) -> (Model, Cmd Msg)
mergeModel model (authModel, cmd) =
    ( { model | auth = authModel }
    , Cmd.map AuthMsg cmd
    )

mergeCmd : Cmd Msg -> (Model, Cmd Msg) -> (Model, Cmd Msg)
mergeCmd cmd (model, newCmd) =
    model ! [cmd, newCmd]

mergeMsg : Msg -> (Model, Cmd Msg) -> (Model, Cmd Msg)
mergeMsg msg (model, cmd) =
    let
        (newModel, newCmd) = update msg model
    in
        newModel ! [cmd, newCmd]

redirectToDashboard : (Model, Cmd Msg) -> (Model, Cmd Msg)
redirectToDashboard (model, cmd) =
    case model.auth.token of
        "" -> mergeMsg NoOp (model, cmd)
        _ -> mergeMsg ShowDashboard (model, cmd)

initSocket : (Model, Cmd Msg) -> (Model, Cmd Msg)
initSocket (model, cmd) =
    let
        user = model.auth.user
    in
        case user of
            AuthModels.LoggedUser currentUser ->
                if model.auth.token /= "" then
                    update (SocketMsg (SocketMessages.InitSocket model.auth.token)) model
                    |> mergeCmd cmd
                else
                    (model , cmd)
            AuthModels.Guest ->
                    (model , cmd)

usersChannel : (Model, Cmd Msg) -> (Model, Cmd Msg)
usersChannel (model, cmd) =
    let
        user = model.auth.user
    in
        case user of
            AuthModels.LoggedUser currentUser ->
                if model.socket.phxSocket.path /= "" then
                    update (SocketMsg (SocketMessages.JoinChannel <| "users:" ++ currentUser.id)) model
                    |> mergeCmd cmd
                else
                    (model , cmd)
            AuthModels.Guest ->
                (model , cmd)

adminsChannel : (Model, Cmd Msg) -> (Model, Cmd Msg)
adminsChannel (model, cmd) =
    let
        user = model.auth.user
    in
        case user of
            AuthModels.LoggedUser currentUser ->
                if currentUser.is_admin && model.socket.phxSocket.path /= "" then
                    update (SocketMsg (SocketMessages.JoinChannel <| "admins:" ++ currentUser.id)) model
                    |> mergeCmd cmd
                else
                    (model , cmd)
            AuthModels.Guest ->
                (model , cmd)

initConnection : AuthMessages.Msg -> Model -> ( Model, Cmd Msg )
initConnection msg model =
    let _ = Debug.log "open socket" model
    in
        Auth.Update.update msg model.auth
        |> mergeModel model
        |> initSocket
        |> usersChannel
        |> adminsChannel

resendSms : Cmd Msg
resendSms =
    let
        task = fromJson JD.string (post "/api/v1/send_sms" JE.null)
    in
        Task.perform
        (\e ->
            let _ = Debug.log "somethign wrong" e
            in NoOp)
        (\_ -> AuthMsg AuthMessages.SmsWasSent)
        task

add : String -> Model -> (Model, Cmd Msg)
add msg model =
    let
        (snackbar, effect) =
            Snackbar.add (Snackbar.toast NoOp msg) model.snackbar
    in
        { model | snackbar = snackbar } ! [ Cmd.map Snackbar effect ]

getFullChannelName : String -> Model -> String
getFullChannelName name model =
    let channel =
        Dict.get "users" model.socket.channels
    in
        --channel
        case channel of
            Nothing -> ""
            Just fullName -> fullName

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case Debug.log "message: " message of
        Mdl message' ->
            Material.update message' model

        SetLocale locale ->
            let
                payload = (JE.string <| toString locale)
                push = Phoenix.Push.init "locale" (getFullChannelName "users" model)
                    |> Phoenix.Push.withPayload payload
                (phxSocket, phxCmd) = Phoenix.Socket.push push model.socket.phxSocket
                socketMsg = model.socket
                socket = { socketMsg | phxSocket = phxSocket }
            in
                { model | socket = socket, locale = locale } ! [ Cmd.map SocketMsg phxCmd ]

        Snackbar msg ->
            let
                (snackbar, cmd) = Snackbar.update msg model.snackbar
            in
                {model | snackbar = snackbar} ! [ Cmd.map Snackbar cmd ]

        AddToast msg -> add msg model

        AuthMsg subMsg ->
            case subMsg of
                AuthMessages.LoadCurrentUser _ ->
                    initConnection subMsg model
                AuthMessages.LoginUser response ->
                    initConnection (AuthMessages.LoginUser response) model
                    |> redirectToDashboard
                AuthMessages.SetToken _ ->
                    initConnection subMsg model
                AuthMessages.RemoveToken ->
                    let
                        (model, cmd) =
                            Auth.Update.update subMsg model.auth
                            |> mergeModel model
                            |> mergeMsg (AuthMsg AuthMessages.RemoveCurrentUser)
                            |> mergeMsg (SocketMsg SocketMessages.RemoveSocket)
                        in
                            model ! [cmd, Task.perform (\_ -> NoOp) (\_ -> ShowLogin) (remove("jwtToken"))]
                AuthMessages.SendSms ->
                    model ! [resendSms]
                AuthMessages.SmsWasSent ->
                    update (AddToast (translate model.locale SmsWasSent)) model
                _ ->
                    Auth.Update.update subMsg model.auth
                    |> mergeModel model

        SocketMsg subMsg ->
            let
                ( updatedSocket, cmd ) =
                    Socket.Update.update subMsg model.socket
            in
                ( { model | socket = updatedSocket }, Cmd.map SocketMsg cmd )

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
