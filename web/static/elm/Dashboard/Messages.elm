module Dashboard.Messages exposing (..)

import Dashboard.Models exposing (..)

type InternalMsg
    = LoadDashboardData Model
    | SetDashboardProjectsType String
    | SetDashboardSort String
    | SetDashboardCurrentPeriod String
    | SetDashboardComparisonPeriod Int
    | NoOp

type OutMsg
    = UpdateDashboardSort String
    | UpdateDashboardCurrentPeriod String
    | UpdateDashboardComparisonPeriod Int
    | UpdateDashboardProjectsType String

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
