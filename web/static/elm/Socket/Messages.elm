module Socket.Messages exposing (..)

import Phoenix.Socket

type Msg
    = InitSocket String
    | JoinChannel String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | NoOp
