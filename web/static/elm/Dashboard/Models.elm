module Dashboard.Models exposing (..)

import Array exposing (..)
import Project.Models exposing (Project)
import Models.Metrics exposing (Metrics(..))

type alias Model =
    { periods : DashboardPeriods
    , charts : DashboardCharts
    , projects : List Project
    , stats : Array ProjectStats
    , totals : TotalStats
    , activeTab : Int
    , splineTooltip : SplineTooltip
    }

type alias SplineTooltip =
    { canvasId : String
    , index : Int
    }

type alias TotalStats =
    { current : Maybe DashboardStatValue
    , comparison : Maybe DashboardStatValue
    }

type alias ProjectStats =
    { id : String
    , values : Array (Maybe DashboardStatValue)
    }

type alias DashboardCharts =
    { stats : DashboardChartStatsData
    , totals : DashboardChartTotalsData
    }

type alias DashboardChartStatsData =
    { daily: Array DashboardDailyChart
    , monthly: Array DashboardMonthlyChart
    }

type alias DashboardChartTotalsData =
    { daily: Array DashboardDailyChartValue
    , monthly: Array DashboardMonthlyChartValue
    }

type alias DashboardDailyChart =
    { project : String
    , values : Array DashboardDailyChartValue
    }

type alias DashboardMonthlyChart =
    { project : String
    , values : Array DashboardMonthlyChartValue
    }

type alias DashboardDailyChartValue =
    { betsAmount : Maybe Int
    , cashoutsAmount : Maybe Int
    , date : String
    , depositsAmount : Maybe Int
    , netgamingAmount : Maybe Int
    , paymentsAmount : Maybe Int
    , rakeAmount : Maybe Int
    , winsAmount : Maybe Int
    }

type alias DashboardMonthlyChartValue =
    { betsAmount : Maybe Int
    , cashoutsAmount : Maybe Int
    , month : String
    , depositsAmount : Maybe Int
    , netgamingAmount : Maybe Int
    , paymentsAmount : Maybe Int
    , rakeAmount : Maybe Int
    , winsAmount : Maybe Int
    }

type alias DashboardPeriods =
    { current : Array String
    , comparison : Array String
    }

type alias DashboardStatValue =
    { authorizationsNumber : Int
    , averageArpu : Float
    , averageDeposit : Float
    , averageFirstDeposit : Float
    , betsAmount : Int
    , cashoutsAmount : Int
    , cashoutsNumber : Int
    , depositorsNumber : Int
    , depositsAmount : Int
    , depositsNumber : Int
    , firstDepositorsNumber : Int
    , firstDepositsAmount : Int
    , netgamingAmount : Int
    , paymentsAmount : Int
    , paymentsNumber : Int
    , rakeAmount : Int
    , signupsNumber : Int
    , winsAmount : Int
    }

emptyCharts =
    { stats = { daily = Array.empty, monthly = Array.empty }
    , totals = { daily = Array.empty, monthly = Array.empty }
    }

initialModel : Model
initialModel =
    { periods = { current = Array.empty, comparison = Array.empty }
    , charts = emptyCharts
    , projects = []
    , stats = Array.empty
    , totals = { current = Nothing, comparison = Nothing }
    , activeTab = 0
    , splineTooltip = { canvasId = "", index = 0 }
    }

getDailyChartValueByMetrics : Metrics -> DashboardDailyChartValue -> Int
getDailyChartValueByMetrics metrics stats =
    let
        value = case metrics of
            BetsAmount -> stats.betsAmount
            CashoutsAmount -> stats.cashoutsAmount
            DepositsAmount -> stats.depositsAmount
            NetgamingAmount -> stats.netgamingAmount
            PaymentsAmount -> stats.paymentsAmount
            RakeAmount -> stats.rakeAmount
            WinsAmount -> stats.winsAmount
            _ -> Nothing
    in case value of
        Nothing -> 0
        Just v -> v

getStatValue : Metrics -> Maybe DashboardStatValue -> Float
getStatValue metrics v = case v of
    Nothing -> 0.0
    Just value -> case metrics of
        AuthorizationsNumber
            -> toFloat value.authorizationsNumber
        AverageArpu
            -> value.averageArpu
        AverageDeposit
            -> value.averageDeposit
        AverageFirstDeposit
            -> value.averageFirstDeposit
        BetsAmount
            -> toFloat value.betsAmount
        CashoutsAmount
            -> abs <| toFloat value.cashoutsAmount
        CashoutsNumber
            -> toFloat value.cashoutsNumber
        DepositorsNumber
            -> toFloat value.depositorsNumber
        DepositsAmount
            -> toFloat value.depositsAmount
        DepositsNumber
            -> toFloat value.depositsNumber
        FirstDepositorsNumber
            -> toFloat value.firstDepositorsNumber
        FirstDepositsAmount
            -> toFloat value.firstDepositsAmount
        NetgamingAmount
            -> toFloat value.netgamingAmount
        PaymentsAmount
            -> toFloat value.paymentsAmount
        PaymentsNumber
            -> toFloat value.paymentsNumber
        RakeAmount
            -> toFloat value.rakeAmount
        SignupsNumber
            -> toFloat value.signupsNumber
        WinsAmount
            -> toFloat value.winsAmount
        NoOp
            -> 0.0
