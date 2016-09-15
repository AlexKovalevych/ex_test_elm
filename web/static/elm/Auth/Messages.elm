module Auth.Messages exposing (..)

import Auth.Models exposing (CurrentUser)
import Auth.Decoders exposing (LoginResponse)
import Translation exposing (Language, TranslationId)
import Json.Encode exposing (Value)

type InternalMsg
    = LoadCurrentUser CurrentUser
    | InitConnection
    | UpdateCurrentUser CurrentUser
    | RemoveCurrentUser
    | LoginFailed String
    | LoginRequest
    | ChangeLoginEmail String
    | ChangeLoginPassword String
    | ChangeLoginCode String
    | SetToken String
    | LoginUser LoginResponse
    | TwoFactor
    | RemoveToken
    | SendSms
    | SmsWasSent
    | LogoutRequest
    | Tick Float
    | NoOp

type OutMsg
    = SocketInit String
    | JoinChannel String
    | RemoveSocket
    | SubscribeToUsersChannel String
    | SubscribeToAdminsChannel String
    | AddToast TranslationId
    | UpdateLocale String
    | ShowLogin
    | ShowDashboard

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg

