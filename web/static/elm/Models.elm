module Models exposing (..)

import Hop.Types exposing (Location)
import Routing exposing (Route)
import Socket.Models as Socket
import Auth.Models as Auth
import Phoenix.Socket

type alias Model =
    { location : Location
    , route : Route
    , socket : Socket.Model
    , auth : Auth.Model
    }

--initialModel : Route -> Location -> Model
--initialModel route location =
--    { location = location
--    , route = route
--    , auth = initAuth
--    , socket = { phxSocket = Phoenix.Socket.init "", channels = [] }
--    }

initialModel : Model
initialModel route location =
  { location = location
  , route = route
  --, article = Article.initialModel
  --, config = Config.initialModel
  --, configError = False
  --, companies = []
  --, events = Event.initialModel
  --, githubAuth = GithubAuth.initialModel
  , auth = Auth.initialModel
  , socket = Socket.initialModel
  --, nextPage = Nothing
  --, user = User.initialModel
  }
