module Models exposing (..)

import Auth.Models as Auth
import Dashboard.Models as Dashboard
import Date
import Hop.Types exposing (Address)
import Material
import Material.Snackbar as Snackbar
import Material.Tooltip as Tooltip
import Messages exposing (..)
import Native.GtDate
import Routing exposing (Route(..), Menu(..), getMenu)
import Socket.Models as Socket
import Translation exposing (Language(..))

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
    , currentDate : Date.Date
    , tooltip : Tooltip.Model
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
    , currentDate = Native.GtDate.now ()
    , tooltip = Tooltip.defaultModel
    --, nextPage = Nothing
    }
