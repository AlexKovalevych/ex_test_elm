module Models exposing (..)

import Hop.Types exposing (Location)
import Routing exposing (Route)


type alias User =
    { email : String
    }


type alias Auth =
    { user : User
    , qrcodeUrl : String
    , error : String
    , smsSent : Bool
    , serverTime: Int
    }

type AuthModel = EmptyAuth | Logged Auth

type alias AppModel =
    { auth : AuthModel
    , location : Location
    , route : Route
    }


newAppModel : AppModel -> Route -> Location -> AppModel
newAppModel initialModel route location =
    { initialModel | location = location, route = route }
