module User.Models exposing (..)

type alias ProjectIds = List String

type alias Permissions =
    { dashboard : DashboardPermissions
    , finance : FinancePermissions
    , statistics : StatisticsPermissions
    , calendar_events : CalendarPermissions
    , players : PlayersPermissions
    }

type alias DashboardPermissions =
    { dashboard_index : ProjectIds
    }

type alias FinancePermissions =
    { payments_check : ProjectIds
    , payment_systems : ProjectIds
    , incoming_reports : ProjectIds
    , funds_flow : ProjectIds
    , monthly_balance : ProjectIds
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

type alias CalendarPermissions =
    { events_groups_list : ProjectIds
    , events_list : ProjectIds
    , events_types_list : ProjectIds
    }

type alias PlayersPermissions =
    { multiaccounts : ProjectIds
    , signup_channels : ProjectIds
    }
