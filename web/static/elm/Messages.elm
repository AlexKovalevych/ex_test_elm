module Messages exposing (..)

import Socket.Messages
import Auth.Messages
import Material
import Material.Snackbar as Snackbar
import Translation exposing (Language, TranslationId)
import Routing exposing (Route, Menu)

type Msg
    = Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg Msg)
    | AddToast TranslationId
    | SetLocale Language
    | UpdateLocale String

    --Socket messages
    | SocketMsg Socket.Messages.InternalMsg

    --Auth messages
    | AuthMsg Auth.Messages.InternalMsg

    --Route messages
    | NavigateTo (Maybe Route)
    | SelectTab Int
    | SetMenu (Maybe Menu)

    | NoOp
