module Dashboard.Models exposing (..)

import Array exposing (..)
import Project.Models exposing (Project)

type alias Model =
    { periods : Array DashboardPeriod
    , charts : DashboardCharts
    , projects : List Project
    , stats : Array (Array DashboardStatValue)
    , totals : Array DashboardStatValue
    }

type alias DashboardCharts =
    { stats : Array (Array DashboardProjectChart)
    , totals : Array (Array DashboardChartValue)
    }

type alias DashboardProjectChart =
    { project : String
    , values : Array DashboardChartValue
    }

type alias DashboardChartValue =
    { betsAmount : Int
    , cashoutsAmount : Int
    , date : String
    , depositsAmount : Int
    , netgamingAmount : Int
    , paymentsAmount : Int
    , rakeAmount : Int
    , winsAmount : Int
    }

type alias DashboardPeriod =
    { from : String
    , to : String
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
    { stats = Array.empty
    , totals = Array.empty
    }

initialModel : Model
initialModel =
    { periods = Array.empty
    , charts = emptyCharts
    , projects = []
    , stats = Array.empty
    , totals = Array.empty
    }
