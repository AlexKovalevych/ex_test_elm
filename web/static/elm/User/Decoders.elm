module User.Decoders exposing (..)

import Json.Decode exposing (..)
import User.Models exposing (..)

projectIdsDecoder : Decoder ProjectIds
projectIdsDecoder =
    list string

permissionsDecoder : Decoder Permissions
permissionsDecoder =
    object5 Permissions
        ("dashboard" := dashboardDecoder)
        ("finance" := financeDecoder)
        ("statistics" := statisticsDecoder)
        ("calendar_events" := calendarEventsDecoder)
        ("players" := playersDecoder)

dashboardDecoder : Decoder DashboardPermissions
dashboardDecoder =
    object1 DashboardPermissions
        ("dashboard_index" := projectIdsDecoder)

financeDecoder : Decoder FinancePermissions
financeDecoder =
    object5 FinancePermissions
        ("payments_check" := projectIdsDecoder)
        ("payment_systems" := projectIdsDecoder)
        ("incoming_reports" := projectIdsDecoder)
        ("funds_flow" := projectIdsDecoder)
        ("monthly_balance" := projectIdsDecoder)

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

calendarEventsDecoder : Decoder CalendarPermissions
calendarEventsDecoder =
    object3 CalendarPermissions
        ("events_groups_list" := projectIdsDecoder)
        ("events_list" := projectIdsDecoder)
        ("events_types_list" := projectIdsDecoder)

playersDecoder : Decoder PlayersPermissions
playersDecoder =
    object2 PlayersPermissions
        ("multiaccounts" := projectIdsDecoder)
        ("signup_channels" := projectIdsDecoder)
