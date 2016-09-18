module Dashboard.View.Spline exposing (..)

import Array exposing (..)
import Auth.Models exposing (CurrentUser)
import Dashboard.Models exposing (DashboardDailyChartValue, getDailyChartValueByMetrics)
import Dashboard.Messages exposing (InternalMsg(..))
import Date.GtDate exposing (dateFromMonthString)
import Formatter exposing (formatMetricsValue, dayFormat)
import Html exposing (..)
import Html.Attributes exposing (id, height, style)
import Html.Events exposing (onMouseLeave)
import Json.Encode as JE
import Messages exposing (Msg(..))
import Models exposing (Model)
import Models.Metrics exposing (Metrics(..), typeToString)
import Native.Chart
import Translation exposing (getDateConfig)
import Date.Extra.Format exposing (format)

type SplineType = Daily | Monthly

splineId : CurrentUser -> Metrics -> Maybe String -> SplineType -> String
splineId user metrics maybeProject splineType =
    let
        project = case maybeProject of
            Nothing -> ""
            Just projectId -> projectId
    in
        (typeToString metrics) ++ project ++ user.settings.dashboardPeriod

dailyChartData : Metrics -> DashboardDailyChartValue -> Int
dailyChartData metrics chartValue =
    let
        getValue v = case v of
            Nothing -> 0
            Just value -> value
        maybeValue = case metrics of
            BetsAmount -> chartValue.betsAmount
            CashoutsAmount -> chartValue.cashoutsAmount
            DepositsAmount -> chartValue.depositsAmount
            NetgamingAmount -> chartValue.netgamingAmount
            PaymentsAmount -> chartValue.paymentsAmount
            RakeAmount -> chartValue.rakeAmount
            WinsAmount -> chartValue.winsAmount
            _ -> Nothing
    in
        getValue maybeValue

areaChart : CurrentUser -> Model -> Metrics -> Maybe String -> Array DashboardDailyChartValue -> Html Msg
areaChart user model metrics maybeProjectId stats =
    let
        canvasId = splineId user metrics maybeProjectId Daily
        data = Array.map (dailyChartData metrics >> JE.int) stats
        |> JE.array
        |> JE.encode 0
        _ = Native.Chart.area canvasId data
    in
        canvas
            [ id canvasId
            , height 40
            , onMouseLeave <| DashboardMsg (SetSplineTooltip {canvasId = "", index = 0})
            ]
            []

areaMetrics : List Metrics
areaMetrics = [PaymentsAmount, DepositsAmount, CashoutsAmount]

areaChartTooltip : CurrentUser -> Model -> Maybe String -> Array DashboardDailyChartValue -> String
areaChartTooltip user model maybeProjectId stats =
    let
        canvasId = model.dashboard.splineTooltip.canvasId
        maybeMetrics = List.filter
            (\metrics -> splineId user metrics maybeProjectId Daily == canvasId)
            areaMetrics
            |> List.head
    in
        case maybeMetrics of
            Just metrics ->
                let
                    index = model.dashboard.splineTooltip.index
                    maybeDate = Array.get index stats
                    formatDate = format (getDateConfig model.locale) dayFormat
                    value = toFloat << (getDailyChartValueByMetrics metrics)
                in
                    case maybeDate of
                        Nothing -> ""
                        Just chartValue ->
                            formatMetricsValue metrics (value chartValue)
                            ++ " ("
                            ++ formatDate (dateFromMonthString chartValue.date)
                            ++ ")"
            Nothing -> ""
