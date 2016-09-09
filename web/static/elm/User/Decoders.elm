module User.Decoders exposing (..)

import Json.Decode exposing (..)
import User.Models exposing (..)

projectIdsDecoder : Decoder ProjectIds
projectIdsDecoder =
    list string

permissionsDecoder : Decoder Permissions
permissionsDecoder =
    object5 Permissions
        ("calendar_events" := calendarEventsDecoder)
        ("dashboard" := dashboardDecoder)
        ("finance" := financeDecoder)
        ("players" := playersDecoder)
        ("statistics" := statisticsDecoder)

calendarEventsDecoder : Decoder CalendarPermissions
calendarEventsDecoder =
    object3 CalendarPermissions
        ("events_groups_list" := projectIdsDecoder)
        ("events_list" := projectIdsDecoder)
        ("events_types_list" := projectIdsDecoder)

dashboardDecoder : Decoder DashboardPermissions
dashboardDecoder =
    object1 DashboardPermissions
        ("dashboard_index" := projectIdsDecoder)

financeDecoder : Decoder FinancePermissions
financeDecoder =
    object5 FinancePermissions
        ("funds_flow" := projectIdsDecoder)
        ("incoming_reports" := projectIdsDecoder)
        ("monthly_balance" := projectIdsDecoder)
        ("payment_systems" := projectIdsDecoder)
        ("payments_check" := projectIdsDecoder)

playersDecoder : Decoder PlayersPermissions
playersDecoder =
    object2 PlayersPermissions
        ("multiaccounts" := projectIdsDecoder)
        ("signup_channels" := projectIdsDecoder)

statisticsDecoder : Decoder StatisticsPermissions
statisticsDecoder =
    object7 StatisticsPermissions
        ("activity_waves" := projectIdsDecoder)
        ("cohorts_report" := projectIdsDecoder)
        ("consolidated_report" := projectIdsDecoder)
        ("ltv_report" := projectIdsDecoder)
        ("retention" := projectIdsDecoder)
        ("segments_report" := projectIdsDecoder)
        ("timeline_report" := projectIdsDecoder)
