module Socket.Messages exposing (..)

import Phoenix.Socket
import Translation exposing (Language)
import Json.Encode exposing (Value)

type InternalMsg
    = InitSocket String
    | JoinChannel String
    | RemoveSocket
    | PushMessage String String Value
    | PhoenixMsg (Phoenix.Socket.Msg InternalMsg)

type OutMsg
    = SetLocale Language

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
