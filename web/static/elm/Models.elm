module Models exposing (..)

import Material
import Hop.Types exposing (Location)
import Routing exposing (Route)
import Socket.Models as Socket
import Auth.Models as Auth
import Translation exposing (Language(..))

type alias Model =
    { mdl : Material.Model
    , location : Location
    , locale : Language
    , route : Route
    , socket : Socket.Model
    , auth : Auth.Model
    }

initialModel : Route -> Location -> Model
initialModel route location =
    { location = location
    , route = route
    , locale = Russian
    , auth = Auth.initialModel
    , socket = Socket.initialModel
    , mdl = Material.model
    --, nextPage = Nothing
    }
