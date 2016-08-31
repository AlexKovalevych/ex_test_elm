module Models exposing (..)

import Hop.Types exposing (Location)
import Routing exposing (Route)
import Socket.Models exposing (Socket)
import Auth.Models exposing (AuthModel, initAuth)
import Phoenix.Socket

type alias Model =
    { location : Location
    , route : Route
    , socket : Socket
    , auth : AuthModel
    }

initialModel : Route -> Location -> Model
initialModel route location =
    { location = location
    , route = route
    , auth = initAuth
    , socket = { phxSocket = Phoenix.Socket.init "", channels = [] }
    }
