module Socket.Models exposing (..)

type alias PlayerId =
    Int


type alias Socket =
    { phxSocket : Phoenix.Socket.Socket Msg
    , channels : List (Phoenix.Socket.Channel)
    }


--new : Player
--new =
--    { id = 0
--    , name = ""
--    , level = 1
--    }
