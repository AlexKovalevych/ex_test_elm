module Socket.Messages exposing (..)

import Phoenix.Socket
import Translation exposing (Language)

type InternalMsg
    = InitSocket String
    | JoinChannel String
    | RemoveSocket
    | PhoenixMsg (Phoenix.Socket.Msg InternalMsg)

type OutMsg
    = SetLocale Language

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
