module Messages exposing (..)

import Socket.Messages
import Auth.Messages

type Msg
    = SocketMsg Socket.Messages.Msg
    | AuthMsg Auth.Messages.Msg
    | ShowDashboard
    | ShowLogin
    | NoOp
