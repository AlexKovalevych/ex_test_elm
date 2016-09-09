module Routing exposing (..)

import Array
import List
import Hop exposing (..)
import Hop.Types exposing (Config)
import UrlParser exposing ((</>), oneOf, int, s)

config : Config
config =
    { basePath = "/"
    , hash = False
    }

routes : UrlParser.Parser (Route -> a) a
routes =
    oneOf matchers

type Route
    = DashboardRoute
    | FinanceRoutes FinanceRoute

    --Other routings
    | LoginRoute
    | NotFoundRoute

type FinanceRoute
    = PaymentCheck
    | PaymentSystem
    | InputReport
    | FundsFlow
    | MonthlyBalances

type Menu
    --= Dashboard
    = Finance
    | Statistics
    | Calendar
    | Players
    | Settings

financeRoutes : List FinanceRoute
financeRoutes = [ PaymentCheck, PaymentSystem, InputReport, FundsFlow, MonthlyBalances ]

matchers : List (UrlParser.Parser (Route -> a) a)
matchers =
    [ UrlParser.format DashboardRoute (s "")
    , UrlParser.format LoginRoute (s "login")
    , UrlParser.format FinanceRoutes (s "finance" </> (oneOf financeMatchers))
    ]

financeMatchers : List (UrlParser.Parser (FinanceRoute -> a) a)
financeMatchers =
    [ UrlParser.format PaymentCheck (s "payments-check" </> s "list")
    , UrlParser.format PaymentSystem (s "payment-system" </> s "list")
    , UrlParser.format InputReport (s "input-report" </> s "list")
    , UrlParser.format FundsFlow (s "finds-flow")
    , UrlParser.format MonthlyBalances (s "monthly-balances")
    ]

reverse : Route -> String
reverse route =
    case route of
        DashboardRoute ->
            ""

        LoginRoute ->
            "/login"

        FinanceRoutes subRoute ->
            "/finance" ++ reverseFinance subRoute

        NotFoundRoute ->
            ""

reverseFinance : FinanceRoute -> String
reverseFinance route =
    case route of
        PaymentCheck ->
            "/payments-check/list"

        PaymentSystem ->
            "/payment-system/list"

        InputReport ->
            "/input-report/list"

        FundsFlow ->
            "/finds-flow"

        MonthlyBalances ->
            "/monthly-balances"

getMenu : Route -> Maybe Menu
getMenu route =
    case route of
        FinanceRoutes _ -> Just Finance
        _ -> Nothing

getMenuRoutings : Menu -> List Route
getMenuRoutings menu =
    case menu of
        Finance -> List.map FinanceRoutes financeRoutes
        _ -> []

routeIsInMenu : Route -> Menu -> Bool
routeIsInMenu route menu =
    case route of
        FinanceRoutes _ -> menu == Finance
        _ -> False

getRouteByTabIndex : Menu -> Int -> Maybe Route
getRouteByTabIndex menu i =
    case menu of
        Finance ->
            getFinanceRouteByIndex i
        _ -> Nothing

getFinanceRouteByIndex : Int -> Maybe Route
getFinanceRouteByIndex index =
    let
        maybeRoute = Array.fromList financeRoutes |> Array.get index
    in
        case maybeRoute of
            Nothing -> Nothing
            Just route -> Just <| FinanceRoutes route
