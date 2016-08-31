module Models exposing (..)

import Hop.Types exposing (Location)
import Routing exposing (Route)
import Messages exposing (..)
import Socket.Models exposing (Socket)

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

type alias Model =
    { socket : Socket
    , auth : AuthModel
    , location : Location
    , route : Route
    }


newAppModel : Model -> Route -> Location -> Model
newAppModel initialModel route location =
    { initialModel | location = location, route = route }
