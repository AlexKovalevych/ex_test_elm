module Project.Models exposing (..)

type alias Project =
    { enabled : Bool
    , id : String
    , isPartner : Bool
    , isPoker : Bool
    , item_id : String
    , prefix : String
    , title : String
    , url : String
    }
