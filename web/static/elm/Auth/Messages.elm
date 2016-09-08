module Auth.Messages exposing (..)

import Auth.Models exposing (CurrentUser)
import Auth.Decoders exposing (LoginResponse)
import Translation exposing (Language, TranslationId)
import Json.Encode exposing (Value)

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
    --| PushMessage String String Value
    | RemoveSocket
    | AddToast TranslationId
    | ShowLogin

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg

