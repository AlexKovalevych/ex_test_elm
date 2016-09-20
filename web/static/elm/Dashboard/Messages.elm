module Dashboard.Messages exposing (..)

import Dashboard.Models exposing (..)
import Models.Metrics exposing (..)

type InternalMsg
    = LoadDashboardData Model
    | SetDashboardProjectsType String
    | SetDashboardSort Metrics
    | SetDashboardCurrentPeriod String
    | SetDashboardComparisonPeriod Int
    | SetSplineTooltip SplineTooltip
    | SetActiveTab Int
    | NoOp

type OutMsg
    = UpdateDashboardData (Maybe String)
    | UpdateDashboardSort String
    | UpdateDashboardCurrentPeriod String
    | UpdateDashboardComparisonPeriod Int
    | UpdateDashboardProjectsType String

type Msg
    = ForSelf InternalMsg
    | ForParent OutMsg
