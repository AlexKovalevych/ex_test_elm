module Socket.Messages exposing (..)

import Phoenix.Socket

type Msg
    = InitSocket String
    | JoinChannel String
    | RemoveSocket
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
