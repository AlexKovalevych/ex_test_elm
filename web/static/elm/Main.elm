port module Main exposing (..)

import Debug
import Navigation
import Hop exposing (matchUrl)
import Hop.Types exposing (Location)
import Routing exposing(Route, config)
import Models exposing (..)
import View exposing (..)
import Update exposing (..)
import Messages exposing (..)


urlParser : Navigation.Parser ( Route, Location )
urlParser =
    Navigation.makeParser (.href >> matchUrl config)


urlUpdate : ( Route, Location ) -> AppModel -> ( AppModel, Cmd Msg )
urlUpdate ( route, location ) model =
    let
        _ =
            Debug.log "urlUpdate location" location
    in
        ( { model | route = route, location = location }, Cmd.none )


--initialModel : AppModel
--initialModel = {}
--initialModel =
--    Maybe.withDefault {} initialState


init : {initialState : String} -> ( Route, Location ) -> ( AppModel, Cmd Msg )
init flags ( route, location ) =
    ( {auth = EmptyAuth, route = route, location = location}, Cmd.none )

initialLocation : Maybe Navigation.Location
initialLocation = Just
    { href = "http://localhost:4000/"
    , host = "localhost:4000"
    , hostname = "localhost"
    , protocol = "http:"
    , origin = "http://localhost:4000"
    , port_ = "4000"
    , pathname = "/"
    , search = ""
    , hash = ""
    , username = ""
    , password = ""
    }


main : Program {initialState : String}
main =
    Navigation.programWithFlags urlParser
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = (always Sub.none)
        , location = initialLocation
        }

--port initialRoute : String

--port initialState : (String -> msg) -> Sub msg

--subscriptions : AppModel -> Sub Msg
--subscriptions model =
--    initialState Init
