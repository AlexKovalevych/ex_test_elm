module Socket.Messages exposing (..)

import Auth.Models exposing (CurrentUser)
import Dashboard.Models
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Phoenix.Socket
import Translation exposing (Language)

type alias PushModel =
    { msg : String
    , channel : String
    , payload : Value
    , successDecoder : Value -> InternalMsg
    , errorDecoder : Value -> InternalMsg
    }

type InternalMsg
    = InitSocket String
    | JoinChannel String
    | RemoveSocket
    | PushMessage PushModel
    | SubscribeToUsersChannel String
    | SubscribeToAdminsChannel String
    | DecodeCurrentUser Value
    | DecodeDashboardData Value
    | PhoenixMsg (Phoenix.Socket.Msg InternalMsg)
    | NoOp

type OutMsg
    = SetLocale Language
    | UpdateCurrentUser CurrentUser
    | UpdateDashboardData Dashboard.Models.Model

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
