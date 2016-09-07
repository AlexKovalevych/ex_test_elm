module Auth.Update exposing (update)

import Auth.Models exposing (Model, User(Guest, LoggedUser))
import Auth.Messages exposing (..)
import Http exposing (fromJson, send, defaultSettings, empty)
import Json.Decode as JD
import Json.Encode as JE
import Task
import Xhr exposing (post, stringFromHttpError)
import Auth.Encoders exposing (encodeLogin, encodeTwoFactor)
import Auth.Decoders exposing (userSuccessDecoder, userErrorDecoder, logoutDecoder)
import LocalStorage exposing (..)

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
        Task.perform (\_ -> NoOp) (\_ -> RemoveToken) task

twoFactor : JE.Value -> Cmd Msg
twoFactor body =
    let
        task = fromJson userSuccessDecoder (post "/api/v1/two_factor" body)
    in
        Task.perform
        (stringFromHttpError >> decodeLoginError >> LoginFailed)
        LoginUser
        task

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadCurrentUser user ->
            { model | user = LoggedUser user, loginFormEmail = "", loginFormPassword = "", loginFormError = "", loginCode = "" } ! []

        RemoveCurrentUser ->
            { model | user = Guest, loginFormEmail = "", loginFormPassword = "", loginFormError = "", loginCode = "" } ! []

        LoginRequest ->
            model ! [ login <| encodeLogin model ]

        LoginFailed msg ->
            { model | loginFormError = msg } ! []

        LoginUser response ->
            case response.jwt of
                Nothing ->
                    let
                        user = response.user
                        model =
                            { model
                            | qrcodeUrl = response.url
                            , serverTime = response.serverTime
                            , user = (LoggedUser user)
                            }
                    in
                        model ! []
                Just token ->
                    let
                        user = response.user
                        model =
                            { model
                            | qrcodeUrl = response.url
                            , serverTime = response.serverTime
                            , user = (LoggedUser user)
                            , token = token
                            }
                    in
                        model ! [Task.perform (\_ -> NoOp) (\_ -> NoOp) (set "jwtToken" token)]

        ChangeLoginEmail msg ->
            { model | loginFormEmail = msg } ! []

        ChangeLoginPassword msg ->
            { model | loginFormPassword = msg } ! []

        ChangeLoginCode msg ->
            { model | loginCode = msg } ! []

        Logout ->
            model ! [logout logoutDecoder]

        SetToken token ->
            { model | token = token } ! []

        RemoveToken ->
            { model | token = "" } ! []

        SendSms ->
            -- Handled at the top level
            model ! []

        SmsWasSent ->
            -- Handled at the top level
            model ! []

        TwoFactor ->
            model ! [ twoFactor <| encodeTwoFactor model ]

        NoOp ->
            model ! []
