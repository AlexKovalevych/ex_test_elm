module Dashboard.Messages exposing (..)

import Dashboard.Models exposing (..)

type InternalMsg
    = LoadDashboardData Model
    | SetDashboardProjectsType String
    | NoOp

type OutMsg
    = UpdateDashboardSort String
    | UpdateDashboardCurrentPeriod String
    | UpdateDashboardComparisonPeriod String
    | UpdateDashboardProjectsType String

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
