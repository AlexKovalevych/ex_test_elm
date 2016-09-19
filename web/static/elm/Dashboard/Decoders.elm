module Dashboard.Decoders exposing (..)

import Dashboard.Models exposing
    ( Model
    , DashboardPeriods
    , DashboardCharts
    , DashboardChartStatsData
    , DashboardDailyChart
    , DashboardMonthlyChart
    , DashboardDailyChartValue
    , DashboardMonthlyChartValue
    , DashboardChartTotalsData
    , DashboardStatValue
    , ProjectStats
    , TotalStats
    , SplineTooltip
    )
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (..)
import Http
import Project.Decoders exposing (projectDecoder)
import Xhr exposing (stringFromHttpError)

dashboardDecoder : Decoder Model
dashboardDecoder =
    object7 Model
        ("periods" := periodsDecoder)
        ("charts" := chartsDecoder)
        ("projects" := list projectDecoder)
        ("stats" := array projectStatsDecoder)
        ("totals" := totalsDecoder)
        ("activeTab" := int)
        ("splineTooltip" := splineDecoder)

periodsDecoder : Decoder DashboardPeriods
periodsDecoder =
    object2 DashboardPeriods
        ("current" := array string)
        ("comparison" := array string)

chartsDecoder : Decoder DashboardCharts
chartsDecoder =
    object2 DashboardCharts
        ("stats" := chartStatsDataDecoder)
        ("totals" := chartTotalsDataDecoder)

chartStatsDataDecoder : Decoder DashboardChartStatsData
chartStatsDataDecoder =
    object2 DashboardChartStatsData
        ("daily" := array dailyChartDecoder)
        ("monthly" := array monthlyChartDecoder)

chartTotalsDataDecoder : Decoder DashboardChartTotalsData
chartTotalsDataDecoder =
    object2 DashboardChartTotalsData
        ("daily" := array dailyChartValueDecoder)
        ("monthly" := array monthlyChartValueDecoder)

dailyChartDecoder : Decoder DashboardDailyChart
dailyChartDecoder =
    object2 DashboardDailyChart
        ("project" := string)
        ("values" := array dailyChartValueDecoder)

monthlyChartDecoder : Decoder DashboardMonthlyChart
monthlyChartDecoder =
    object2 DashboardMonthlyChart
        ("project" := string)
        ("values" := array monthlyChartValueDecoder)

dailyChartValueDecoder : Decoder DashboardDailyChartValue
dailyChartValueDecoder =
    object8 DashboardDailyChartValue
        (maybe ("betsAmount" := int))
        (maybe ("cashoutsAmount" := int))
        ("date" := string)
        (maybe ("depositsAmount" := int))
        (maybe ("netgamingAmount" := int))
        (maybe ("paymentsAmount" := int))
        (maybe ("rakeAmount" := int))
        (maybe ("winsAmount" := int))

monthlyChartValueDecoder : Decoder DashboardMonthlyChartValue
monthlyChartValueDecoder =
    object8 DashboardMonthlyChartValue
        (maybe ("betsAmount" := int))
        (maybe ("cashoutsAmount" := int))
        ("month" := string)
        (maybe ("depositsAmount" := int))
        (maybe ("netgamingAmount" := int))
        (maybe ("paymentsAmount" := int))
        (maybe ("rakeAmount" := int))
        (maybe ("winsAmount" := int))

projectStatsDecoder : Decoder ProjectStats
projectStatsDecoder =
    object2 ProjectStats
        ("id" := string)
        ("values" := array (maybe statValueDecoder))

totalsDecoder : Decoder TotalStats
totalsDecoder =
    object2 TotalStats
        ("current" := maybe statValueDecoder)
        ("comparison" := maybe statValueDecoder)

statValueDecoder : Decoder DashboardStatValue
statValueDecoder =
    succeed DashboardStatValue
        |: ("authorizationsNumber" := int)
        |: ("averageArpu" := float)
        |: ("averageDeposit" := float)
        |: ("averageFirstDeposit" := float)
        |: ("betsAmount" := int)
        |: ("cashoutsAmount" := int)
        |: ("cashoutsNumber" := int)
        |: ("depositorsNumber" := int)
        |: ("depositsAmount" := int)
        |: ("depositsNumber" := int)
        |: ("firstDepositorsNumber" := int)
        |: ("firstDepositsAmount" := int)
        |: ("netgamingAmount" := int)
        |: ("paymentsAmount" := int)
        |: ("paymentsNumber" := int)
        |: ("rakeAmount" := int)
        |: ("signupsNumber" := int)
        |: ("winsAmount" := int)

splineDecoder : Decoder SplineTooltip
splineDecoder =
    object2 SplineTooltip
        ("canvasId" := string)
        ("index" := int)

--userSuccessDecoder : Decoder LoginResponse
--userSuccessDecoder =
--    object4 LoginResponse
--        ("user" := userDecoder)
--        (maybe ("jwt" := string))
--        (maybe ("url" := string))
--        (maybe ("serverTime" := int))


--userErrorDecoder : Http.Error -> String
--userErrorDecoder msg =
--    let
--        stringMsg = stringFromHttpError msg
--    in
--        case decodeString (at ["error"] string) stringMsg of
--            Ok error -> error
--            Err _ -> ""
