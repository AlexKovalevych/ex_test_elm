module Auth.Update exposing (..)

import Auth.Models exposing (Model, User(Guest, LoggedUser))
import Auth.Messages exposing (..)
import Task
import LocalStorage exposing (..)
import Translation exposing (..)
import Auth.Api exposing (logout, login, twoFactor, sendSms)
import Update.Never exposing (never)

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
                { newModel | user = LoggedUser user } !
                    [ Cmd.map (ForSelf << (\_ -> InitConnection)) Cmd.none
                    , Task.perform never ForParent (Task.succeed <| UpdateLocale user.locale ) ]

        RemoveCurrentUser ->
            let
                newModel = resetLoginForm model
            in
                { newModel | user = Guest } ! []

        LoginRequest ->
            model ! [ login model ]

        LoginFailed msg ->
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
                    LoggedUser user ->
                        [ Task.perform never ForSelf (Task.succeed InitConnection)
                        , Task.perform never ForParent (Task.succeed ShowDashboard)
                        ]
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
                model ! [ Cmd.map ForParent (Cmd.map (\_ -> AddToast msg) Cmd.none) ]

        TwoFactor ->
            model ! [ twoFactor model ]

        Tick _ ->
            case model.serverTime of
                Nothing -> model ! []
                Just time -> { model | serverTime = Just (time + 1000) } ! []

        UpdateCurrentUser user ->
            { model | user = LoggedUser user } !
                [ Task.perform never ForParent (Task.succeed <| UpdateLocale user.locale ) ]

        NoOp ->
            model ! []

initConnection : String -> Bool -> String -> List ( Cmd Msg )
initConnection token isAdmin userId =
    let
        usersChannel = "users:" ++ userId
        adminsChannel = "admins:" ++ userId
        task =
            [ Task.perform never ForParent (Task.succeed <| SubscribeToUsersChannel usersChannel )
            , Task.perform never ForParent (Task.succeed <| JoinChannel usersChannel )
            , Task.perform never ForParent (Task.succeed <| SocketInit token)
            ]
    in
        if isAdmin then
            [ Task.perform never ForParent (Task.succeed <| SubscribeToAdminsChannel adminsChannel )
            , Task.perform never ForParent (Task.succeed <| JoinChannel adminsChannel )
            ] ++ task
        else
            task

type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onSocketInit : String -> msg
    , onSocketRemove : msg
    , onJoinChannel : String -> msg
    , onSubscribeToUsersChannel : String -> msg
    , onSubscribeToAdminsChannel : String -> msg
    , onAddToast : TranslationId -> msg
    , onUpdateLocale : String -> msg
    , onShowLogin : msg
    , onShowDashboard : msg
    }

type alias Translator msg =
    Msg -> msg

translator : TranslationDictionary msg -> Translator msg
translator
    { onInternalMessage
    , onSocketInit
    , onSocketRemove
    , onJoinChannel
    , onSubscribeToUsersChannel
    , onSubscribeToAdminsChannel
    , onAddToast
    , onUpdateLocale
    , onShowLogin
    , onShowDashboard
    } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (SocketInit token) ->
            onSocketInit token

        ForParent (JoinChannel name) ->
            onJoinChannel name

        ForParent RemoveSocket ->
            onSocketRemove

        ForParent (SubscribeToUsersChannel channel) ->
            onSubscribeToUsersChannel channel

        ForParent (SubscribeToAdminsChannel channel) ->
            onSubscribeToAdminsChannel channel

        ForParent (AddToast msg) ->
            onAddToast msg

        ForParent (UpdateLocale locale) ->
            onUpdateLocale locale

        ForParent ShowLogin ->
            onShowLogin

        ForParent ShowDashboard ->
            onShowDashboard

resetLoginForm : Model -> Model
resetLoginForm model =
    { model
    | loginFormEmail = ""
    , loginFormPassword = ""
    , loginFormError = ""
    , loginCode = ""
    }
