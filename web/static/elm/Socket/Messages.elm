module Socket.Messages exposing (..)

import Auth.Models exposing (CurrentUser)
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Phoenix.Socket
--import Socket.Decoders exposing (PushModel)
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
    | PhoenixMsg (Phoenix.Socket.Msg InternalMsg)
    | NoOp

type OutMsg
    = SetLocale Language
    | UpdateCurrentUser CurrentUser

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
