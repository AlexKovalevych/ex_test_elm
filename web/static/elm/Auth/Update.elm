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
        Task.perform (\_ -> NoOp) (\_ -> RemoveToken) task

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadCurrentUser user ->
            ( { model | user = LoggedUser user }
            , Cmd.none
            )

        --Need to do:
        --1. Logout ajax request (Set guest as user to model)
        --2. Remove token from the storage
        --3. Redirect to login page
        Logout ->
            ( { model | user = Guest }
            , logout (Json.string)
            )

        SetToken token ->
            ( { model | token = token }
            , Cmd.none
            )

        RemoveToken ->
            ( { model | token = "" }
            , Cmd.none
            )

        NoOp ->
            model ! []
