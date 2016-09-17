module Dashboard.View.Spline exposing (..)

import Array exposing (..)
import Auth.Models exposing (CurrentUser)
import Dashboard.Models exposing (DashboardStatValue, DashboardDailyChartValue, getValueByMetrics)

type SplineType = Daily | Monthly

splineId : CurrentUser -> String -> Maybe String -> SplineType -> String
splineId user metrics maybeProject splineType =
    let
        project = case maybeProject of
            Nothing -> ""
            Just projectId -> projectId
    in
        metrics ++ project ++ user.settings.dashboardPeriod

dailyChartData : String -> DashboardDailyChartValue -> Int
dailyChartData metrics chartValue =
    let
        getValue v = case v of
            Nothing -> 0
            Just value -> value
        maybeValue = case metrics of
            "betsAmount" -> chartValue.betsAmount
            "cashoutsAmount" -> chartValue.cashoutsAmount
            "depositsAmount" -> chartValue.depositsAmount
            "netgamingAmount" -> chartValue.netgamingAmount
            "paymentsAmount" -> chartValue.paymentsAmount
            "rakeAmount" -> chartValue.rakeAmount
            "winsAmount" -> chartValue.winsAmount
            _ -> Nothing
    in
        getValue maybeValue
