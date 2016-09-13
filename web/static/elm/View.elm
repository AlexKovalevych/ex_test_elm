module View exposing (..)

import Auth.Messages as AuthMessages
import Auth.Models exposing(User(Guest, LoggedUser), CurrentUser)
import Auth.View as AuthView
import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class, href, style, src, alt)
import Material.Scheme
import Material.Layout as Layout
import Material.Options as Options
import Material.Color as Color
import Material.Snackbar as Snackbar
import Material.Icon as Icon
import Messages exposing (..)
import Models exposing (..)
import Routing exposing (Route(..))
import View.Header as Header
import View.Menu
import Dashboard.View

view : Model -> Html Msg
view model =
    if model.auth.token == ""
    then
        AuthView.view model
    else
        case model.auth.user of
            LoggedUser user ->
                Layout.render Mdl model.mdl
                    [ Layout.fixedHeader
                    , Layout.fixedDrawer
                    , Layout.onSelectTab SelectTab
                    ]
                    { header = Header.header user model
                    , drawer = drawer user model
                    , tabs = (Header.tabs user model, [])
                    , main =
                        [ div
                            [ style [ ( "padding", "1rem" ) ] ]
                            [ body model user
                            , Snackbar.view model.snackbar |> App.map Snackbar
                            ]
                        ]
                    }
            Guest -> AuthView.view model

drawer : CurrentUser -> Model -> List (Html Msg)
drawer user model =
    [ Layout.title []
        [ text "Globotunes 3.0" ]
    , Layout.navigation
        [ Options.css "flex-grow" "1" ]
        (View.Menu.menu user model)
    ]

body : Model -> CurrentUser -> Html Msg
body model user =
    case model.route of
        DashboardRoute ->
            Dashboard.View.view model user

        NotFoundRoute ->
            notFoundView model

        _ ->
            text "Hello world"

notFoundView : Model -> Html msg
notFoundView model =
    div []
        [ text "Not Found"
        ]
