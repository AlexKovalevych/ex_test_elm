module Socket.Models exposing (..)

import Phoenix.Socket
import Phoenix.Channel exposing (Channel)
import Socket.Messages exposing (InternalMsg)
import Dict exposing (Dict, empty)

type alias Model =
    { phxSocket : Phoenix.Socket.Socket InternalMsg
    , channels : Dict String String
    }

initialModel : Model
initialModel =
    { phxSocket = Phoenix.Socket.init ""
    , channels = empty
    }
