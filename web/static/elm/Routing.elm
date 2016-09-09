module Routing exposing (..)

import Array
import List
import Hop exposing (..)
import Hop.Types exposing (Config, PathMatcher)
import Hop.Matchers exposing (..)

type Route
    = DashboardRoute

    --Finance routings
    | PaymentCheck
    --| PaymentSystem
    --| InputReport
    --| FundsFlow
    --| MonthlyBalances

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
financeRoutes = [ PaymentCheck ]

getMenu : Route -> Maybe Menu
getMenu location =
    if List.member location financeRoutes then
        Just Finance
    else
        Nothing

getMenuRoutings : Menu -> List Route
getMenuRoutings menu =
    case menu of
        Finance -> [ PaymentCheck ]
        _ -> []

getRouteByTabIndex : Menu -> Int -> Maybe Route
getRouteByTabIndex menu i =
    case menu of
        Finance ->
            Array.fromList financeRoutes
            |> Array.get i
        _ -> Nothing

matcherDashboard : PathMatcher Route
matcherDashboard =
    match1 DashboardRoute "/"

matcherLogin : PathMatcher Route
matcherLogin =
    match1 LoginRoute "/login"

matcherPaymentCheck : PathMatcher Route
matcherPaymentCheck =
    match1 PaymentCheck "/finance/payments-check/list"

matchers : List (PathMatcher Route)
matchers =
    [ matcherDashboard
    , matcherLogin
    ]

config : Config Route
config =
    { basePath = "/"
    , hash = False
    , matchers = matchers
    , notFound = NotFoundRoute
    }

reverse : Route -> String
reverse route =
    case route of
        DashboardRoute ->
            matcherToPath matcherDashboard []

        LoginRoute ->
            matcherToPath matcherLogin []

        PaymentCheck ->
            matcherToPath matcherPaymentCheck []

        NotFoundRoute ->
            ""
