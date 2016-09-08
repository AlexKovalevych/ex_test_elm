module Auth.Update exposing (..)

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
import Translation exposing (..)

update : InternalMsg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        InitConnection ->
            case model.user of
                Guest -> model ! []
                LoggedUser user -> model ! [ Cmd.map ForParent (Cmd.map (\_ -> SocketInit model.token) Cmd.none) ]

        LoadCurrentUser user ->
            let
                newModel = resetLoginForm model
            in
                { newModel | user = LoggedUser user } ! []

        RemoveCurrentUser ->
            let
                newModel = resetLoginForm model
            in
                { newModel | user = Guest } ! []

        LoginRequest ->
            model ! [ Cmd.map ForSelf <| login <| encodeLogin model ]

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
                        model ! [Task.perform (\_ -> ForSelf NoOp) (\_ -> ForSelf NoOp) (set "jwtToken" token)]

        ChangeLoginEmail msg ->
            { model | loginFormEmail = msg } ! []

        ChangeLoginPassword msg ->
            { model | loginFormPassword = msg } ! []

        ChangeLoginCode msg ->
            { model | loginCode = msg } ! []

        Logout ->
            model ! [ Cmd.map ForSelf <| logout logoutDecoder]

        SetToken token ->
            { model | token = token } ! []

        RemoveToken ->
            { model | token = "" } ! []

        SendSms ->
            let
                task = fromJson JD.string (post "/api/v1/send_sms" JE.null)
            in
                model ! [Task.perform
                    (\e -> ForSelf NoOp)
                    (\_ -> ForSelf SmsWasSent)
                    task
                ]

        SmsWasSent ->
            let
                msg = Login "sms_was_sent"
            in
                model ! [ Cmd.map ForParent (Cmd.map (\e -> AddToast msg) Cmd.none) ]

        TwoFactor ->
            model ! [ Cmd.map ForSelf <| twoFactor <| encodeTwoFactor model ]

        Tick _ ->
            case model.serverTime of
                Nothing -> model ! []
                Just time -> { model | serverTime = Just (time + 1000) } ! []

        NoOp ->
            model ! []

type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onSocketInit : String -> msg
    , onAddToast : TranslationId -> msg
    }

type alias Translator msg =
    Msg -> msg

translator : TranslationDictionary msg -> Translator msg
translator { onInternalMessage, onSocketInit, onAddToast } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (SocketInit token) ->
            onSocketInit token

        ForParent (AddToast msg) ->
            onAddToast msg

resetLoginForm : Model -> Model
resetLoginForm model =
    { model
    | loginFormEmail = ""
    , loginFormPassword = ""
    , loginFormError = ""
    , loginCode = ""
    }

decodeLoginError : String -> String
decodeLoginError msg =
    case JD.decodeString userErrorDecoder msg of
        Ok error -> error
        Err _ -> ""

login : JE.Value -> Cmd InternalMsg
login body =
    let
        task = fromJson userSuccessDecoder (post "/api/v1/auth" body)
    in
        Task.perform
        (stringFromHttpError >> decodeLoginError >> LoginFailed)
        LoginUser
        task

logout : JD.Decoder value -> Cmd InternalMsg
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

twoFactor : JE.Value -> Cmd InternalMsg
twoFactor body =
    let
        task = fromJson userSuccessDecoder (post "/api/v1/two_factor" body)
    in
        Task.perform
        (stringFromHttpError >> decodeLoginError >> LoginFailed)
        LoginUser
        task
