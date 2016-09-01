module Models exposing (..)

import Material
import Hop.Types exposing (Location)
import Routing exposing (Route)
import Socket.Models as Socket
import Auth.Models as Auth

type alias Model =
    { mdl : Material.Model
    , location : Location
    , route : Route
    , socket : Socket.Model
    , auth : Auth.Model
    }

initialModel : Route -> Location -> Model
initialModel route location =
    { location = location
    , route = route
    , auth = Auth.initialModel
    , socket = Socket.initialModel
    , mdl = Material.model
    --, nextPage = Nothing
    --, user = User.initialModel
    }
