module View.Menu exposing (..)

import Html exposing (..)
import List
import Messages exposing (..)
import Models exposing (..)
import Material.Color as Color
import Material.Icon as Icon
import Material.Layout as Layout
import Material.Options as Options
import Routing exposing (Route(..), Menu(..), routeIsInMenu)
import Translation exposing (..)

menu : Model -> List (Html Msg)
menu model =
    List.map (drawerMenuItem model) <| menuItems model

type MenuItem
    = Submenu
        { text : String
        , iconName : String
        , menu : Menu
        }
    | DirectLink
        { text : String
        , iconName : String
        , route : Route
        }

menuItems : Model -> List MenuItem
menuItems model =
    [ DirectLink { text = translate model.locale (Menu "dashboard"), iconName = "dashboard", route = DashboardRoute }
    , Submenu { text = translate model.locale (Menu "finance"), iconName = "account_balance", menu = Finance }
    --, { text = "Users", iconName = "group", route = Just Users }
    --, { text = "Last Activity", iconName = "alarm", route = Nothing }
    --, { text = "Timesheets", iconName = "event", route = Nothing }
    --, { text = "Reports", iconName = "list", route = Nothing }
    --, { text = "Organizations", iconName = "store", route = Just Organizations }
    --, { text = "Projects", iconName = "view_list", route = Just Projects }
    ]

menuAction : MenuItem -> Msg
menuAction menuItem =
    case menuItem of
        DirectLink item -> NavigateTo <| Just item.route
        Submenu item -> SetMenu <| Just item.menu

drawerMenuItem : Model -> MenuItem -> Html Msg
drawerMenuItem model menuItem =
    let
        _ = Debug.log "HERE: " model.route
        isActive = case menuItem of
            Submenu item ->
                routeIsInMenu model.route item.menu
            DirectLink item ->
                model.route == item.route

        iconName = case menuItem of
            Submenu item -> item.iconName
            DirectLink item -> item.iconName
        itemText = case menuItem of
            Submenu item -> item.text
            DirectLink item -> item.text
    in
        Layout.link
            [ Layout.onClick ( menuAction menuItem )
            , Options.css "cursor" "pointer"
            , (Color.text <| Color.accent) `Options.when` isActive
            ]
            [ Icon.view iconName
                [ Options.css "margin-right" "8px"
                ]
            , text itemText
            ]
