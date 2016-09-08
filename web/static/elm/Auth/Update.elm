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
import Auth.Api exposing (logout, login, twoFactor, sendSms)

update : InternalMsg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        InitConnection ->
            case model.user of
                Guest -> model ! []
                LoggedUser user -> model ! initConnection model.token user.is_admin user.id

        LoadCurrentUser user ->
            let
                newModel = resetLoginForm model
            in
                { newModel | user = LoggedUser user } ! [ Cmd.map ForSelf (Cmd.map (\_ -> InitConnection) Cmd.none) ]

        RemoveCurrentUser ->
            let
                newModel = resetLoginForm model
            in
                { newModel | user = Guest } ! []

        LoginRequest ->
            model ! [ Cmd.map ForSelf <| login <| encodeLogin model ]

        LoginFailed msg ->
            let _ = Debug.log "failed: " msg
            in
            { model | loginFormError = msg } ! []

        LoginUser response ->
            let
                user = response.user
                newModel =
                    { model
                    | qrcodeUrl = response.url
                    , serverTime = response.serverTime
                    , user = (LoggedUser user)
                    }
            in
                case response.jwt of
                    Nothing -> newModel ! []
                    Just token ->
                        { newModel | token = token } !
                            [ Task.perform (\_ -> ForSelf NoOp) (\_ -> ForSelf (SetToken token)) (set "jwtToken" token)
                            ]

        ChangeLoginEmail msg ->
            { model | loginFormEmail = msg } ! []

        ChangeLoginPassword msg ->
            { model | loginFormPassword = msg } ! []

        ChangeLoginCode msg ->
            { model | loginCode = msg } ! []

        LogoutRequest ->
            model ! [ logout ]

        SetToken token ->
            let
                task = case model.user of
                    Guest -> []
                    LoggedUser user -> [ Task.perform never ForSelf (Task.succeed InitConnection) ]
            in
                { model | token = token } ! task

        RemoveToken ->
            let
                newModel = resetLoginForm model
            in { newModel | token = "", user = Guest } !
                [ Task.perform (\_ -> ForSelf NoOp) (\_ -> ForParent ShowLogin) (remove "jwtToken")
                , Task.perform never ForParent (Task.succeed RemoveSocket)
                ]

        SendSms ->
            model ! [ sendSms ]

        SmsWasSent ->
            let
                msg = Login "sms_was_sent"
            in
                model ! [ Cmd.map ForParent (Cmd.map (\e -> AddToast msg) Cmd.none) ]

        TwoFactor ->
            model ! [ twoFactor <| encodeTwoFactor model ]

        Tick _ ->
            case model.serverTime of
                Nothing -> model ! []
                Just time -> { model | serverTime = Just (time + 1000) } ! []

        NoOp ->
            model ! []

initConnection : String -> Bool -> String -> List ( Cmd Msg )
initConnection token isAdmin userId =
    let
        task =
            [ Task.perform never ForParent (Task.succeed <| JoinChannel <| "users:" ++ userId)
            , Task.perform never ForParent (Task.succeed <| SocketInit token)
            ]
    in
        if isAdmin then
            Task.perform never ForParent (Task.succeed <| JoinChannel <| "admins:" ++ userId) :: task
        else
            task

never : Never -> a
never n =
    never n

type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onSocketInit : String -> msg
    , onSocketRemove : msg
    , onJoinChannel : String -> msg
    , onAddToast : TranslationId -> msg
    , onShowLogin : msg
    }

type alias Translator msg =
    Msg -> msg

translator : TranslationDictionary msg -> Translator msg
translator { onInternalMessage, onSocketInit, onSocketRemove, onJoinChannel, onAddToast, onShowLogin } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (SocketInit token) ->
            onSocketInit token

        ForParent (JoinChannel name) ->
            onJoinChannel name

        ForParent RemoveSocket ->
            onSocketRemove

        ForParent (AddToast msg) ->
            onAddToast msg

        ForParent ShowLogin ->
            onShowLogin

resetLoginForm : Model -> Model
resetLoginForm model =
    { model
    | loginFormEmail = ""
    , loginFormPassword = ""
    , loginFormError = ""
    , loginCode = ""
    }
