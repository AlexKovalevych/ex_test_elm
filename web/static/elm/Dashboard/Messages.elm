module Dashboard.Messages exposing (..)

import Dashboard.Models exposing (..)

type InternalMsg
    = LoadDashboardData Model
    | NoOp

type OutMsg
    = SetDashboardSort String
    | SetDashboardChartType String
    | SetDashboardPeriod String

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
