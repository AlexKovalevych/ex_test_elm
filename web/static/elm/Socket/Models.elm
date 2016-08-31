module Socket.Models exposing (..)

import Phoenix.Socket
import Phoenix.Channel exposing (Channel)
import Socket.Messages exposing (Msg)

type alias Socket =
    { phxSocket : Phoenix.Socket.Socket Msg
    , channels : List (Channel String)
    }
