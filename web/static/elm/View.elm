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
import Routing exposing (Route(..), Menu(..))
import View.Header as Header

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
                    , Layout.fixedTabs
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
        (List.map (drawerMenuItem model) <| menuItems model)
    ]

type alias MenuItem =
    { text : String
    , iconName : String
    , route : Maybe Route
    , menu : Maybe Menu
    }

menuItems : Model -> List MenuItem
menuItems model =
    [ { text = translate model.locale (Menu "dashboard"), iconName = "dashboard", route = Just DashboardRoute, menu = Nothing }
    , { text = translate model.locale (Menu "finance"), iconName = "account_balance", route = Nothing, menu = Just Finance }
    --, { text = "Users", iconName = "group", route = Just Users }
    --, { text = "Last Activity", iconName = "alarm", route = Nothing }
    --, { text = "Timesheets", iconName = "event", route = Nothing }
    --, { text = "Reports", iconName = "list", route = Nothing }
    --, { text = "Organizations", iconName = "store", route = Just Organizations }
    --, { text = "Projects", iconName = "view_list", route = Just Projects }
    ]

menuAction route menu =
    case menu of
        Nothing -> NavigateTo route
        Just _ -> SetMenu menu

drawerMenuItem : Model -> MenuItem -> Html Msg
drawerMenuItem model menuItem =
    Layout.link
        [ Layout.onClick ( menuAction menuItem.route menuItem.menu )
        ]
--        [ Layout.onClick (NavigateTo menuItem.route)
--        , (Color.text <| Color.accent) `when` (model.route == menuItem.route)
--        , Options.css "font-weight" "500"
--        , Options.css "cursor" "pointer"
--          -- http://outlinenone.com/ TODO: tl;dr don't do this
--          -- Should be using ":focus { outline: 0 }" for this but can't do that with inline styles so this is a hack til I get a proper stylesheet on here.
--        , Options.css "outline" "none"
--        ]
        [ Icon.view menuItem.iconName
            [ Options.css "margin-right" "8px"
            ]
        , text menuItem.text
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

        PaymentCheck ->
            div [ class "row" ]
            []

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
