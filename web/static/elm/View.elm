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
import Material.Grid exposing (grid, noSpacing, maxWidth, cell, size, offset, Device(..))
import Material.Icon as Icon
import Messages exposing (..)
import Models exposing (..)
import Routing exposing (Route(..))
import Translation exposing (..)
import View.Header as Header
import View.Menu

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
                    , drawer = drawer model
                    , tabs = (Header.tabs user model, [])
                    , main =
                        [ div
                            [ style [ ( "padding", "1rem" ) ] ]
                            [ body model
                            , Snackbar.view model.snackbar |> App.map Snackbar
                            ]
                        ]
                    }
            Guest -> AuthView.view model

drawer : Model -> List (Html Msg)
drawer model =
    [ Layout.title []
        [ text "Globotunes 3.0" ]
    , Layout.navigation
        [ Options.css "flex-grow" "1" ]
        (View.Menu.menu model)
    ]

body : Model -> Html Msg
body model =
    text "Hello world"

--pageView : Model -> Html Msg
--pageView model =
--    case model.route of
--        DashboardRoute ->
--            div [ class "p2" ]
--                [ h1 [ id "title", class "m0" ] [ text "Dashboard" ]
--                , div [] [ text "Click on Languages to start routing" ]
--                ]

--        LoginRoute ->
--            div [ class "row" ]
--                [ div [ class "col-xs-offset-4 col-xs-4" ] []
--                ]

--        PaymentCheck ->
--            div [ class "row" ]
--            []

--        PaymentCheck ->
--            div [ class "row" ]
--            []

        --LanguagesRoutes languagesRoute ->
        --    let
        --        viewModel =
        --            { languages = model.languages
        --            , route = languagesRoute
        --            , location = model.location
        --            }
        --    in
        --        div [ class "p2" ]
        --            [ h1 [ id "title", class "m0" ] [ text "Languages" ]
        --            , Html.App.map LanguagesMsg (Languages.View.view viewModel)
        --            ]

        --NotFoundRoute ->
        --    notFoundView model


notFoundView : Model -> Html msg
notFoundView model =
    div []
        [ text "Not Found"
        ]
