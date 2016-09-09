module User.Models exposing (..)

type alias ProjectIds = List String

type alias Permissions =
    { calendar_events : CalendarPermissions
    , dashboard : DashboardPermissions
    , finance : FinancePermissions
    , players : PlayersPermissions
    , statistics : StatisticsPermissions
    }

type alias CalendarPermissions =
    { events_groups_list : ProjectIds
    , events_list : ProjectIds
    , events_types_list : ProjectIds
    }

type alias DashboardPermissions =
    { dashboard_index : ProjectIds
    }

type alias FinancePermissions =
    { funds_flow : ProjectIds
    , incoming_reports : ProjectIds
    , monthly_balance : ProjectIds
    , payment_systems : ProjectIds
    , payments_check : ProjectIds
    }

type alias PlayersPermissions =
    { multiaccounts : ProjectIds
    , signup_channels : ProjectIds
    }

type alias StatisticsPermissions =
    { activity_waves : ProjectIds
    , cohorts_report : ProjectIds
    , consolidated_report : ProjectIds
    , ltv_report : ProjectIds
    , retention : ProjectIds
    , segments_report : ProjectIds
    , timeline_report : ProjectIds
    }
