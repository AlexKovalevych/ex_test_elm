module Messages exposing (..)

import Auth.Messages
import Dashboard.Messages
import Material
import Material.Snackbar as Snackbar
import Material.Tooltip as Tooltip
import Routing exposing (Route, Menu)
import Socket.Messages
import Translation exposing (Language, TranslationId)

type Msg
    = Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg Msg)
    | AddToast TranslationId
    | SetLocale Language
    | UpdateLocale String
    | TooltipMsg Tooltip.Msg

    --Socket messages
    | SocketMsg Socket.Messages.InternalMsg

    --Auth messages
    | AuthMsg Auth.Messages.InternalMsg

    --Dashboard messages
    | DashboardMsg Dashboard.Messages.InternalMsg

    --Route messages
    | NavigateTo Route
    | SelectTab Int
    | SetMenu (Maybe Menu)

    | NoOp
