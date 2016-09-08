module Messages exposing (..)

import Socket.Messages
import Auth.Messages
import Material
import Material.Snackbar as Snackbar
import Translation exposing (Language)

type Msg
    = SocketMsg Socket.Messages.Msg
    | Mdl (Material.Msg Msg)
    | SetLocale Language
    | Snackbar (Snackbar.Msg Msg)
    | AddToast String
    | AuthMsg Auth.Messages.Msg
    | ShowDashboard
    | ShowLogin
    | NoOp
