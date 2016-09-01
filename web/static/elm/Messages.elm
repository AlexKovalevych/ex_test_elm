module Messages exposing (..)

import Socket.Messages
import Auth.Messages
import Material

type Msg
    = SocketMsg Socket.Messages.Msg
    | Mdl (Material.Msg Msg)
    | AuthMsg Auth.Messages.Msg
    | ShowDashboard
    | ShowLogin
    | NoOp
