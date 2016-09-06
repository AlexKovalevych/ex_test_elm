module Models exposing (..)

import Material
import Material.Snackbar as Snackbar
import Hop.Types exposing (Location)
import Routing exposing (Route)
import Socket.Models as Socket
import Auth.Models as Auth
import Translation exposing (Language(..))
import Messages exposing (..)

type alias Model =
    { mdl : Material.Model
    , location : Location
    , locale : Language
    , route : Route
    , socket : Socket.Model
    , auth : Auth.Model
    , snackbar : Snackbar.Model (Maybe Msg)
    }

initialModel : Route -> Location -> Model
initialModel route location =
    { location = location
    , route = route
    , locale = Russian
    , auth = Auth.initialModel
    , socket = Socket.initialModel
    , mdl = Material.model
    , snackbar = Snackbar.model
    --, nextPage = Nothing
    }
