module Messages exposing (..)

import Phoenix.Socket

type Msg
    = ShowDashboard
    | ShowLogin
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
