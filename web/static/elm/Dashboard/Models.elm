module Dashboard.Models exposing (..)

import Array exposing (..)
import Project.Models exposing (Project)

type alias Model =
    { periods : DashboardPeriods
    , charts : DashboardCharts
    , projects : List Project
    , stats : Array ProjectStats
    , totals : TotalStats
    , activeTab : Int
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
    }

getValueByMetrics : String -> DashboardStatValue -> Float
getValueByMetrics metrics stats =
    case metrics of
        "authorizationsNumber"
            -> toFloat stats.authorizationsNumber
        "averageArpu"
            -> stats.averageArpu
        "averageDeposit"
            -> stats.averageDeposit
        "averageFirstDeposit"
            -> stats.averageFirstDeposit
        "betsAmount"
            -> toFloat stats.betsAmount
        "cashoutsAmount"
            -> toFloat stats.cashoutsAmount
        "cashoutsNumber"
            -> toFloat stats.cashoutsNumber
        "depositorsNumber"
            -> toFloat stats.depositorsNumber
        "depositsAmount"
            -> toFloat stats.depositsAmount
        "depositsNumber"
            -> toFloat stats.depositsNumber
        "firstDepositorsNumber"
            -> toFloat stats.firstDepositorsNumber
        "firstDepositsAmount"
            -> toFloat stats.firstDepositsAmount
        "netgamingAmount"
            -> toFloat stats.netgamingAmount
        "paymentsAmount"
            -> toFloat stats.paymentsAmount
        "paymentsNumber"
            -> toFloat stats.paymentsNumber
        "rakeAmount"
            -> toFloat stats.rakeAmount
        "signupsNumber"
            -> toFloat stats.signupsNumber
        "winsAmount"
            -> toFloat stats.winsAmount
        _
            -> 0.0
