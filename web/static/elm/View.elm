module View exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class, href, style, src, alt)
import Models exposing (..)
import Messages exposing (..)
import Routing exposing (..)
import Auth.Models exposing(User(Guest, LoggedUser), CurrentUser)
import Auth.Messages as AuthMessages
import Material.Scheme
import Material.Layout as Layout
import Material.Options as Options
import Material.Color as Color
import Material.Snackbar as Snackbar
import Material.Grid exposing (grid, noSpacing, maxWidth, cell, size, offset, Device(..))
import Material.Icon as Icon
import Translation exposing (..)
import Auth.View as AuthView

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
                    ]
                    { header = header user
                    , drawer = drawer model
                    , tabs = ( [], [] )
                    , main =
                        [ div
                            [ style [ ( "padding", "1rem" ) ] ]
                            [ body model
                            , Snackbar.view model.snackbar |> App.map Snackbar
                            ]
                        ]
                    }
            Guest -> AuthView.view model

    --case model.route of
    --    LoginRoute ->
    --    _ ->
    --div []
    --    [ menu model
    --    , pageView model
    --    ]


header : CurrentUser -> List (Html Msg)
header user =
    [ Layout.row
        []
        [ Layout.title [] [ text "Page title here" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link
                []
                [ text user.email ]
            , Layout.link
                [ Layout.onClick <| AuthMsg (AuthMessages.Logout)
                ]
                [ Icon.i "exit_to_app" ]
            ]
        ]
    ]

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
