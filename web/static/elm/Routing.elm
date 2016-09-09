module Routing exposing (..)

import Array
import List
import Hop exposing (..)
import Hop.Types exposing (Config, PathMatcher)
import Hop.Matchers exposing (..)

config : Config Route
config =
    { basePath = "/"
    , hash = False
    , matchers = matchers
    , notFound = NotFoundRoute
    }

type Route
    = DashboardRoute

    --Finance routings
    | PaymentCheck
    | PaymentSystem
    | InputReport
    | FundsFlow
    | MonthlyBalances

    --Other routings
    | LoginRoute
    | NotFoundRoute

type Menu
    --= Dashboard
    = Finance
    | Statistics
    | Calendar
    | Players
    | Settings

financeRoutes : List Route
financeRoutes = [ PaymentCheck, PaymentSystem, InputReport, FundsFlow, MonthlyBalances ]

matchers : List (PathMatcher Route)
matchers =
    [ matcherDashboard
    , matcherPaymentCheck
    , matcherPaymentSystem
    , matcherInputReport
    , matcherFundsFlow
    , matcherMonthlyBalances
    , matcherLogin
    ]

reverse : Route -> String
reverse route =
    case route of
        DashboardRoute ->
            matcherToPath matcherDashboard []

        LoginRoute ->
            matcherToPath matcherLogin []

        PaymentCheck ->
            matcherToPath matcherPaymentCheck []

        PaymentSystem ->
            matcherToPath matcherPaymentSystem []

        InputReport ->
            matcherToPath matcherInputReport []

        FundsFlow ->
            matcherToPath matcherFundsFlow []

        MonthlyBalances ->
            matcherToPath matcherMonthlyBalances []

        NotFoundRoute ->
            ""

getMenu : Route -> Maybe Menu
getMenu location =
    if List.member location financeRoutes then
        Just Finance
    else
        Nothing

getMenuRoutings : Menu -> List Route
getMenuRoutings menu =
    case menu of
        Finance -> financeRoutes
        _ -> []

routeIsInMenu : Route -> Menu -> Bool
routeIsInMenu route menu =
    case menu of
        Finance -> List.member route financeRoutes
        _ -> False

getRouteByTabIndex : Menu -> Int -> Maybe Route
getRouteByTabIndex menu i =
    case menu of
        Finance ->
            Array.fromList financeRoutes |> Array.get i
        _ -> Nothing

matcherDashboard : PathMatcher Route
matcherDashboard =
    match1 DashboardRoute ""

matcherLogin : PathMatcher Route
matcherLogin =
    match1 LoginRoute "/login"

matcherPaymentCheck : PathMatcher Route
matcherPaymentCheck =
    match1 PaymentCheck "/finance/payments-check/list"

matcherPaymentSystem : PathMatcher Route
matcherPaymentSystem =
    match1 PaymentSystem "/finance/payment-system/list"

matcherInputReport : PathMatcher Route
matcherInputReport =
    match1 InputReport "/finance/input-report/list"

matcherFundsFlow : PathMatcher Route
matcherFundsFlow =
    match1 FundsFlow "/finance/funds-flow/"

matcherMonthlyBalances : PathMatcher Route
matcherMonthlyBalances =
    match1 MonthlyBalances "/finance/monthly-balances/"
