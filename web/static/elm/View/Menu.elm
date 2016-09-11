module View.Menu exposing (..)

import Auth.Models exposing (CurrentUser)
import Html exposing (..)
import List
import Messages exposing (..)
import Models exposing (..)
import Material.Color as Color
import Material.Icon as Icon
import Material.Layout as Layout
import Material.Options as Options
import Routing exposing
    ( Route(..)
    , FinanceRoute(..)
    , StatisticRoute(..)
    , CalendarRoute(..)
    , PlayerRoute(..)
    , SettingsRoute(..)
    , Menu(..)
    , routeIsInMenu
    , getMenuRoutings
    )
import Translation exposing (..)

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

menu : CurrentUser -> Model -> List (Html Msg)
menu user model =
    menuItems model
    |> List.filter (hasAccessToMenu user)
    |> List.map (drawerMenuItem model)

hasAccessToMenu : CurrentUser -> MenuItem -> Bool
hasAccessToMenu user menu =
    case user.is_admin of
        True -> True
        False ->
            case menu of
                DirectLink item ->
                    hasAccessToRoute user item.route
                Submenu item ->
                    List.any (hasAccessToRoute user) (getMenuRoutings item.menu)

hasAccessToRoute : CurrentUser -> Route -> Bool
hasAccessToRoute user route =
    let
        dashboard = user.permissions.dashboard
        finance = user.permissions.finance
        statistics = user.permissions.statistics
        calendar = user.permissions.calendar_events
        players = user.permissions.players
    in
        not <| List.isEmpty <| case route of
            DashboardRoute ->
                dashboard.dashboard_index

            FinanceRoutes (PaymentCheckRoutes _) ->
                finance.payments_check

            FinanceRoutes (PaymentSystemRoutes _) ->
                finance.payment_systems

            FinanceRoutes InputReport ->
                finance.incoming_reports

            FinanceRoutes FundsFlow ->
                finance.funds_flow

            FinanceRoutes MonthlyBalances ->
                finance.monthly_balance

            StatisticRoutes ConsolidatedReport ->
                statistics.consolidated_report

            StatisticRoutes LtvReport ->
                statistics.ltv_report

            StatisticRoutes SegmentsReport ->
                statistics.segments_report

            StatisticRoutes RetentionsReport ->
                statistics.retention

            StatisticRoutes ActivityWaves ->
                statistics.activity_waves

            StatisticRoutes TimelineReport ->
                statistics.timeline_report

            StatisticRoutes CohortsReport ->
                statistics.cohorts_report

            CalendarRoutes (EventsRoutes _) ->
                calendar.events_list

            CalendarRoutes (EventsTypesRoutes _) ->
                calendar.events_types_list

            CalendarRoutes (EventsGroupsRoutes _) ->
                calendar.events_groups_list

            PlayersRoutes Multiaccounts ->
                players.multiaccounts

            PlayersRoutes (SignupChannelsRoutes _) ->
                players.signup_channels

            SettingsRoutes _ ->
                if user.is_admin then
                    [""]
                else
                    []

            _ ->
                []

drawerMenuItem : Model -> MenuItem -> Html Msg
drawerMenuItem model menuItem =
    let
        (isActive, iconName, itemText) = case menuItem of
            Submenu item ->
                (routeIsInMenu model.route item.menu, item.iconName, item.text)
            DirectLink item ->
                (model.route == item.route, item.iconName, item.text)
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

menuItems : Model -> List MenuItem
menuItems model =
    [ DirectLink
        { text = translate model.locale (Menu "dashboard")
        , iconName = "dashboard"
        , route = DashboardRoute
        }
    , Submenu
        { text = translate model.locale (Menu "finance")
        , iconName = "account_balance"
        , menu = Finance
        }
    , Submenu
        { text = translate model.locale (Menu "statistics")
        , iconName = "show_chart"
        , menu = Statistics
        }
    , Submenu
        { text = translate model.locale (Menu "calendar_events")
        , iconName = "event"
        , menu = Calendar
        }
    , Submenu
        { text = translate model.locale (Menu "players")
        , iconName = "account_box"
        , menu = Players
        }
    , Submenu
        { text = translate model.locale (Menu "settings")
        , iconName = "settings"
        , menu = Settings
        }
    ]

menuAction : MenuItem -> Msg
menuAction menuItem =
    case menuItem of
        DirectLink item -> NavigateTo item.route
        Submenu item -> SetMenu <| Just item.menu
