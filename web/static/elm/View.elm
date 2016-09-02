module View exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class, href, style)
import Models exposing (..)
import Messages exposing (..)
import Routing exposing (..)
import Material.Scheme
import Material.Layout as Layout
import Material.Options as Options
import Material.Color as Color
import Material.Snackbar as Snackbar
import Material.Grid exposing (grid, noSpacing, maxWidth, cell, size, offset, Device(..))
import Material.Icon as Icon

view : Model -> Html Msg
view model =
    case model.route of
        LoginRoute ->
            div [] []
        _ ->
                Layout.render Mdl model.mdl
                    [ Layout.fixedHeader
                    , Layout.fixedDrawer
                    ]
                    { header = header model
                    , drawer = drawer model
                    , tabs = ( [], [] )
                    , main =
                        [ div
                            [ style [ ( "padding", "1rem" ) ] ]
                            [ body model
                            --, Snackbar.view model.snackbar |> App.map Snackbar
                            ]
                        ]
                    }
    --div []
    --    [ menu model
    --    , pageView model
    --    ]


header : Model -> List (Html Msg)
header model =
    [ Layout.row
        []
        [ Layout.title [] [ text "Page title here" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link
                []
                [ text "elm-package" ]
            , Layout.link
                [ Layout.href "http://package.elm-lang.org/packages/debois/elm-mdl/latest/" ]
                [ Icon.i "photo" ]
            ]
        ]
    ]
    --[
    --    grid [ Options.css "width" "100%" ]
    --        [ cell [ size All 8 ]
    --            [ text "Page Title goes here"
    --            ]
    --        , cell [ size All 4 ]
    --            [ div [] [text "Logout and username goes here"]
    --            ]
    --        ]
    --]


drawer : Model -> List (Html Msg)
drawer model =
    [ Layout.title []
        [ text "Globotunes 3.0" ]
    , Layout.navigation
        [ Options.css "flex-grow" "1" ]
        []
    ]

body : Model -> Html Msg
body model =
    text "Hello world"

--menu : Model -> Html Msg
--menu model =
--    case model.route of
--        LoginRoute ->
--            div [] []
--        _ ->
--            div [ class "p2 white bg-black" ]
--                [ div []
--                    [ menuLink ShowDashboard "btnHome" "Dashboard"
--                    , text "|"
--                    , menuLink ShowLogin "btnLogin" "Login"
--                    ]
--                ]


--menuLink : Msg -> String -> String -> Html Msg
--menuLink message viewId label =
--    a
--        [ id viewId
--        , href "javascript://"
--        , onClick message
--        , class "white px2"
--        ]
--        [ text label ]


pageView : Model -> Html Msg
pageView model =
    case model.route of
        DashboardRoute ->
            div [ class "p2" ]
                [ h1 [ id "title", class "m0" ] [ text "Dashboard" ]
                , div [] [ text "Click on Languages to start routing" ]
                ]

        LoginRoute ->
            div [ class "row" ]
                [ div [ class "col-xs-offset-4 col-xs-4" ] []
                ]

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

        NotFoundRoute ->
            notFoundView model


notFoundView : Model -> Html msg
notFoundView model =
    div []
        [ text "Not Found"
        ]
