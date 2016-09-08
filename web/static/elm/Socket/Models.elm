module Socket.Models exposing (..)

import Phoenix.Socket
import Phoenix.Channel exposing (Channel)
import Socket.Messages exposing (Msg)
import Dict exposing (Dict, empty)

type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , channels : Dict String String
    }

initialModel : Model
initialModel =
    { phxSocket = Phoenix.Socket.init ""
    , channels = empty
    }
