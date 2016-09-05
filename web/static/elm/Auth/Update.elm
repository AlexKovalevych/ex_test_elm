module Auth.Update exposing (update)

import Auth.Models exposing (Model, User(Guest, LoggedUser))
import Auth.Messages exposing (..)
import Http exposing (fromJson, send, defaultSettings, empty)
import Json.Decode as JD
import Json.Encode as JE
import Task
import Xhr exposing (post, stringFromHttpError)
import Auth.Encoders exposing (encodeLogin)
import Auth.Decoders exposing (userSuccessDecoder, userErrorDecoder, logoutDecoder)

decodeLoginError : String -> String
decodeLoginError msg =
    case JD.decodeString userErrorDecoder msg of
        Ok error -> error
        Err _ -> ""

login : JE.Value -> Cmd Msg
login body =
    let
        task = fromJson userSuccessDecoder (post "/api/v1/auth" body)
    in
        Task.perform
        (stringFromHttpError >> decodeLoginError >> LoginFailed)
        LoginUser
        --(\response ->
        --    if response.url == Nothing && response.serverTime == Nothing
        --    then Cmd.batch ([ LoadCurrentUser response.user ])
        --    else Cmd.batch ([
        --        LoadCurrentUser response.user,
        --        SetQrData response.url response.serverTime
        --    ])
        --)
        task

logout : JD.Decoder value -> Cmd Msg
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
        Task.perform
            (\e ->
                let _ = Debug.log "error: " e
                in
                    NoOp
            )
            (\v ->
                let _ = Debug.log "success: " v
                in RemoveToken
            ) task

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadCurrentUser user ->
            ( { model | user = LoggedUser user, loginFormEmail = "", loginFormPassword = "", loginFormError = "" }
            , Cmd.none
            )

        LoginRequest ->
            model ! [login <| encodeLogin model ]

        LoginFailed msg ->
            ( { model | loginFormError = msg }
            , Cmd.none
            )

        LoginUser response ->
            let
                user = response.user
                model =
                    { model
                    | qrcodeUrl = response.url
                    , serverTime = response.serverTime
                    , user = (LoggedUser user)
                    , token = response.jwt
                    }
            in
                update (LoadCurrentUser user) model

        ChangeLoginEmail msg ->
            ( { model | loginFormEmail = msg }
            , Cmd.none )

        ChangeLoginPassword msg ->
            ( { model | loginFormPassword = msg }
            , Cmd.none )

        --Need to do:
        --1. Logout ajax request
        --2. Remove token from the storage
        --3. Set guest as user to model
        --4. Redirect to login page
        Logout ->
            ( model
            , logout logoutDecoder
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
