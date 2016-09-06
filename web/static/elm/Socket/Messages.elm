module Socket.Messages exposing (..)

import Phoenix.Socket

type Msg
    = InitSocket String
    | JoinChannel String
    | LeaveChannel String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
