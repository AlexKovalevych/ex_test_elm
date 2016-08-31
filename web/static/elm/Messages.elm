module Messages exposing (..)

import Socket.Messages

type Msg
    = SocketMsg Socket.Messages.Msg
    | ShowDashboard
    | ShowLogin
    | NoOp
