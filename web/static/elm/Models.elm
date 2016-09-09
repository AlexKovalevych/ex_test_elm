module Models exposing (..)

import Material
import Material.Snackbar as Snackbar
import Hop.Types exposing (Location)
import Routing exposing (Route, Menu(..))
import Socket.Models as Socket
import Auth.Models as Auth
import Translation exposing (Language(..))
import Messages exposing (..)

type alias Model =
    { mdl : Material.Model
    , location : Location
    , locale : Language
    , route : Route
    , menu : Maybe Menu
    , socket : Socket.Model
    , channels : List String
    , auth : Auth.Model
    , snackbar : Snackbar.Model Msg
    }

initialModel : Route -> Location -> Model
initialModel route location =
    { location = location
    , route = route
    , locale = Russian
    , auth = Auth.initialModel
    , socket = Socket.initialModel
    , channels = []
    , mdl = Material.model
    , snackbar = Snackbar.model
    , menu = Nothing
    --, nextPage = Nothing
    }
