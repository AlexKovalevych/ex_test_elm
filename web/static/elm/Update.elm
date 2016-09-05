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
    Auth.Update.update msg model.auth
    |> mergeModel model
    |> initSocket
    |> usersChannel
    |> adminsChannel

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case Debug.log "message: " message of
        Mdl message' ->
            Material.update message' model

        AuthMsg subMsg ->
            case subMsg of
                AuthMessages.LoadCurrentUser _ ->
                    initConnection subMsg model
                --AuthMessages.LoginUser response ->
                --    Auth.Update.update subMsg response
                --    |> mergeModel model
                    --|> initSocket
                    --|> usersChannel
                    --|> adminsChannel
                    --|> mergeMsg ShowDashboard
                AuthMessages.SetToken _ ->
                    initConnection subMsg model
                AuthMessages.RemoveToken ->
                    let
                        (model, cmd) =
                            Auth.Update.update subMsg model.auth
                            |> mergeModel model
                        _ = Debug.log "wtg" model
                        in
                            model ! [cmd, Task.perform (\_ -> NoOp) (\_ -> ShowLogin) (remove("jwtToken"))]
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
                ( model, navigationCmd path )

        ShowLogin ->
            let
                path =
                    reverse LoginRoute
            in
                ( model, navigationCmd path )

        NoOp ->
            model ! []
