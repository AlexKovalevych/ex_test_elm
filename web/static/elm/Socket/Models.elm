module Socket.Models exposing (..)

import Phoenix.Socket
import Phoenix.Channel exposing (Channel)
import Socket.Messages exposing (Msg, NoOp)

type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , channels : List (Channel String)
    }

initialModel : Model
initialModel =
    { phxSocket = Phoenix.Socket.Socket NoOp
    , channels = []
    }
