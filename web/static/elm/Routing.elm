module Routing exposing (..)

import Hop exposing (..)
import Hop.Types exposing (Config, PathMatcher)
import Hop.Matchers exposing (..)

type Route
    = DashboardRoute
    | LoginRoute
    | NotFoundRoute

matcherDashboard : PathMatcher Route
matcherDashboard =
    match1 DashboardRoute ""

matcherLogin : PathMatcher Route
matcherLogin =
    match1 LoginRoute "/login"

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

        NotFoundRoute ->
            ""
