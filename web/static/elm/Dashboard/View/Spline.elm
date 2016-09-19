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

splineId : Metrics -> Maybe String -> SplineType -> String
splineId metrics maybeProject splineType =
    let
        project = case maybeProject of
            Nothing -> ""
            Just projectId -> projectId
    in
        (typeToString metrics) ++ project ++ (toString splineType)

dailyChartData : Metrics -> DashboardDailyChartValue -> Int
dailyChartData metrics chartValue =
    let
        maybeValue = case metrics of
            BetsAmount -> chartValue.betsAmount
            CashoutsAmount -> chartValue.cashoutsAmount
            DepositsAmount -> chartValue.depositsAmount
            NetgamingAmount -> chartValue.netgamingAmount
            PaymentsAmount -> chartValue.paymentsAmount
            RakeAmount -> chartValue.rakeAmount
            WinsAmount -> chartValue.winsAmount
            _ -> Nothing
        value = case maybeValue of
            Nothing -> 0
            Just value -> value
    in
        case metrics of
            CashoutsAmount -> abs value
            _ -> value

areaChart : CurrentUser -> Model -> Metrics -> Maybe String -> Array DashboardDailyChartValue -> Html Msg
areaChart user model metrics maybeProjectId stats =
    let
        canvasId = splineId metrics maybeProjectId Daily
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

areaChartTooltip : Model -> Metrics -> Maybe String -> Array DashboardDailyChartValue -> String
areaChartTooltip model metrics maybeProjectId stats =
    let
        canvasId = model.dashboard.splineTooltip.canvasId
    in
        if splineId metrics maybeProjectId Daily == canvasId then
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
        else
            ""
