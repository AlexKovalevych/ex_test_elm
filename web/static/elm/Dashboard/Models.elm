module Dashboard.Models exposing (..)

import Array exposing (..)
import Project.Models exposing (Project)

type alias Model =
    { periods : DashboardPeriods
    , charts : DashboardCharts
    , projects : List Project
    , stats : Array (Array (Maybe DashboardStatValue))
    , totals : Array (Maybe DashboardStatValue)
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
    , totals = Array.empty
    }

getCurrentValueBySort : DashboardStatValue -> String -> Float
getCurrentValueBySort stats sortBy =
    case sortBy of
        "authorizationsNumber" -> stats.authorizationsNumber
        "averageArpu" -> stats.averageArpu
        "averageDeposit" -> stats.averageDeposit
        "averageFirstDeposit" -> stats.averageFirstDeposit
        "betsAmount" -> stats.betsAmount
        "cashoutsAmount" -> stats.cashoutsAmount
        "cashoutsNumber" -> stats.cashoutsNumber
        "depositorsNumber" -> stats.depositorsNumber
        "depositsAmount" -> stats.depositsAmount
        "depositsNumber" -> stats.depositsNumber
        "firstDepositorsNumber" -> stats.firstDepositorsNumber
        "firstDepositsAmount" -> stats.firstDepositsAmount
        "netgamingAmount" -> stats.netgamingAmount
        "paymentsAmount" -> stats.paymentsAmount
        "paymentsNumber" -> stats.paymentsNumber
        "rakeAmount" -> stats.rakeAmount
        "signupsNumber" -> stats.signupsNumber
        "winsAmount" -> stats.winsAmount

--formatCashValue
--formatCashValue value =

