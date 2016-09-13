module Dashboard.Messages exposing (..)

import Dashboard.Models exposing (..)

type InternalMsg
    = LoadDashboardData Model
    | NoOp

type OutMsg
    = SetDashboardSort String
    | SetDashboardCurrentPeriod String
    | SetDashboardComparisonPeriod String
    | SetDashboardProjectsType String

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
