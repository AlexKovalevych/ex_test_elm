module Auth.Messages exposing (..)

import Auth.Models exposing (CurrentUser)
import Auth.Decoders exposing (LoginResponse)
import Translation exposing (TranslationId)

type InternalMsg
    = LoadCurrentUser CurrentUser
    | InitConnection
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
    | AddToast TranslationId
    | ShowLogin

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg

