module Dashboard.View.Spline exposing (..)

import Array exposing (..)
import Auth.Models exposing (CurrentUser)
import ColorManager exposing (dashboardMetricsColor)
import Dashboard.Models exposing
    ( DashboardDailyChartValue
    , DashboardMonthlyChartValue
    , getDailyChartValueByMetrics
    , getMonthlyChartValueByMetrics
    )
import Dashboard.Messages exposing (InternalMsg(..))
import Date.GtDate exposing (dateFromMonthString)
import Formatter exposing (formatMetricsValue, dayFormat, monthFormat)
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

splineId : Metrics -> String -> SplineType -> String
splineId metrics index splineType =
    (typeToString metrics) ++ index ++ (toString splineType)

dailyChartData : Metrics -> DashboardDailyChartValue -> Float
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
            CashoutsAmount -> toFloat <| abs value
            _ -> toFloat value

monthlyChartData : Metrics -> DashboardMonthlyChartValue -> Float
monthlyChartData metrics chartValue =
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
            CashoutsAmount -> toFloat <| abs value
            _ -> toFloat value

areaChart : CurrentUser -> Model -> Metrics -> String -> Array DashboardDailyChartValue -> Html Msg
areaChart user model metrics index stats =
    let
        formatDate = format (getDateConfig model.locale) dayFormat
        canvasId = splineId metrics index Daily
        data = [ stats ]
        |> List.map (\dataset -> Array.map (dailyChartData metrics >> formatMetricsValue metrics >> JE.string) dataset)
        |> Array.fromList
        |> Array.map JE.array
        |> JE.array
        |> JE.encode 0
        labels = Array.map (\v -> JE.string <| formatDate <| dateFromMonthString v.date) stats
        |> JE.array
        |> JE.encode 0
        _ = Native.Chart.area canvasId (Array.fromList [dashboardMetricsColor metrics]) index data labels
    in
        div
            [ style [ ("margin-bottom", "5px"), ("width", "100%"), ("height", "40px") ]
            , id canvasId
            , height 25
            , onMouseLeave <| DashboardMsg (SetSplineTooltip {canvasId = "", index = 0})
            ]
            []

barChart : CurrentUser -> Model -> Metrics -> String -> Array DashboardMonthlyChartValue -> Html Msg
barChart user model metrics index stats =
    let
        formatDate = format (getDateConfig model.locale) monthFormat
        canvasId = splineId metrics index Monthly
        data = [ stats ]
        |> List.map (\dataset -> Array.map (monthlyChartData metrics >> formatMetricsValue metrics >> JE.string) dataset)
        |> Array.fromList
        |> Array.map JE.array
        |> JE.array
        |> JE.encode 0
        labels = Array.map (\v -> JE.string <| formatDate <| dateFromMonthString <| v.month) stats
        |> JE.array
        |> JE.encode 0
        _ = Native.Chart.bar canvasId (Array.fromList [dashboardMetricsColor metrics]) index data labels
    in
        div
            [ style [ ("width", "100%"), ("height", "40px") ]
            , id canvasId
            , height 25
            , onMouseLeave <| DashboardMsg (SetSplineTooltip {canvasId = "", index = 0})
            ]
            []

areaChartTooltip : Model -> Metrics -> String -> Array DashboardDailyChartValue -> List String
areaChartTooltip model metrics projectIndex stats =
    let
        canvasId = model.dashboard.splineTooltip.canvasId
    in
        if splineId metrics projectIndex Daily == canvasId then
            let
                index = model.dashboard.splineTooltip.index
                maybeDate = Array.get index stats
                formatDate = format (getDateConfig model.locale) dayFormat
                value = toFloat << (getDailyChartValueByMetrics metrics)
            in
                case maybeDate of
                    Nothing -> [ "" ]
                    Just chartValue ->
                        [ formatMetricsValue metrics (value chartValue)
                        ++ " ("
                        ++ formatDate (dateFromMonthString chartValue.date)
                        ++ ")"
                        ]
        else
            [ "" ]

barChartTooltip : Model -> Metrics -> String -> Array DashboardMonthlyChartValue -> List String
barChartTooltip model metrics projectIndex stats =
    let
        canvasId = model.dashboard.splineTooltip.canvasId
    in
        if splineId metrics projectIndex Monthly == canvasId then
            let
                index = model.dashboard.splineTooltip.index
                maybeDate = Array.get index stats
                formatDate = format (getDateConfig model.locale) monthFormat
                value = toFloat << (getMonthlyChartValueByMetrics metrics)
            in
                case maybeDate of
                    Nothing -> [ "" ]
                    Just chartValue ->
                        [ formatMetricsValue metrics (value chartValue)
                        ++ " ("
                        ++ formatDate (dateFromMonthString chartValue.month)
                        ++ ")"
                        ]
        else
            [ "" ]
