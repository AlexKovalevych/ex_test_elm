module Messages exposing (..)

import Socket.Messages
import Auth.Messages
import Material
import Material.Snackbar as Snackbar

type Msg
    = SocketMsg Socket.Messages.Msg
    | Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg (Maybe Msg))
    | AddToast String
    | AuthMsg Auth.Messages.Msg
    | ShowDashboard
    | ShowLogin
    | NoOp
