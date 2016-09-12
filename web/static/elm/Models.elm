module Models exposing (..)

import Dashboard.Models as Dashboard
import Material
import Material.Snackbar as Snackbar
import Hop.Types exposing (Address)
import Routing exposing (Route(..), Menu(..), getMenu)
import Socket.Models as Socket
import Auth.Models as Auth
import Translation exposing (Language(..))
import Messages exposing (..)

type alias Model =
    { mdl : Material.Model
    , address : Address
    , locale : Language
    , route : Route
    , menu : Maybe Menu
    , socket : Socket.Model
    , dashboard : Dashboard.Model
    , channels : List String
    , auth : Auth.Model
    , snackbar : Snackbar.Model Msg
    }

initialModel : Route -> Address -> Model
initialModel route address =
    { address = address
    , route = route
    , locale = Russian
    , auth = Auth.initialModel
    , socket = Socket.initialModel
    , dashboard = Dashboard.initialModel
    , channels = []
    , mdl = Material.model
    , snackbar = Snackbar.model
    , menu = getMenu route
    --, nextPage = Nothing
    }
