module Messages exposing (..)

import Phoenix.Socket

type Msg
    = ShowDashboard
    | InitSocket String
    | JoinChannel String
    | ShowLogin
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
