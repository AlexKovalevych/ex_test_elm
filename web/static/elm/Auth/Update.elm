module Auth.Update exposing (update)

import Auth.Models exposing (Model, User(Guest, LoggedUser))
import Auth.Messages exposing (..)
import Http exposing (fromJson, send, defaultSettings, empty)
import Json.Decode as Json
import Task

logout : Json.Decoder value -> Cmd Msg
logout decoder =
    let request =
        { verb = "DELETE"
        , headers = [
            ("Accept", "application/json"),
            ("Content-Type", "application/json")
        ]
        , url = "/api/v1/auth"
        , body = empty
        }
        task = fromJson decoder (send defaultSettings request)
    in
        Task.perform (\e ->
            let _ = Debug.log "error: " e
            in
                NoOp) (\v ->
                let _ = Debug.log "success: " v
                in RemoveToken) task

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadCurrentUser user ->
            ( { model | user = LoggedUser user }
            , Cmd.none
            )

        --Need to do:
        --1. Logout ajax request
        --2. Remove token from the storage
        --3. Set guest as user to model
        --4. Redirect to login page
        Logout ->
            ( model
            , logout (Json.string)
            )

        SetToken token ->
            ( { model | token = token }
            , Cmd.none
            )

        RemoveToken ->
            ( { model | token = "", user = Guest }
            , Cmd.none
            )

        NoOp ->
            model ! []
