module Dashboard.View exposing (..)

import Array exposing (..)
import Auth.Models exposing (CurrentUser)
import Color
import ColorManager exposing (dashboardMetricsColor, rgbaToString)
import Dashboard.Messages as DashboardMessages exposing (Msg(..), OutMsg(..), InternalMsg(..))
import Dashboard.Models exposing
    ( DashboardStatValue
    , DashboardPeriods
    , getStatValue
    , TotalStats
    , ProjectStats
    , DashboardChartTotalsData
    , DashboardChartStatsData
    , getDailyChartValueByMetrics
    )
import Dashboard.View.Delta exposing (delta)
import Dashboard.View.Spline exposing (..)
import Date
import Date.GtDate exposing (dateFromMonthString)
import Date.Extra.Duration as Duration
import Date.Extra.Format exposing (format)
import Formatter exposing (formatMetricsValue, dayFormat, monthFormat, yearFormat)
import Html exposing (..)
import Html.Attributes exposing (id, height, style)
import Material.Button as Button
import Material.Elevation as Elevation
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Options as Options
import Material.Progress as Progress
import Material.Tabs as Tabs
import Material.Toggles as Toggles
import Material.Typography as Typography
import Messages exposing (..)
import Models exposing (..)
import Models.Metrics as Metrics
import Translation exposing (..)
import Project.Models exposing (Project)

view : Model -> CurrentUser -> Html Messages.Msg
view model user =
    let
        metrics = Metrics.stringToType user.settings.dashboardSort
        totals = model.dashboard.totals
        stats = model.dashboard.stats
        sortedStats = getSortedStats metrics stats
        maximumValue = getMaximumStatsValue metrics totals sortedStats
    in
        div []
            [ grid []
                [ cell [ size All 12 ]
                    [ span []
                        [ text <| translate model.locale <| Dashboard "projects_type"
                        , Button.render Mdl [0] model.mdl
                            (projectProps user "default")
                            [ text <| translate model.locale <| Dashboard "default_projects" ]
                        , Button.render Mdl [1] model.mdl
                            (projectProps user "partners")
                            [ text <| translate model.locale <| Dashboard "partner_projects" ]
                        ]
                    ]
                , cell [ size Desktop 4, size Tablet 3, size Phone 12 ]
                    [ span []
                        <| [ text <| translate model.locale <| Dashboard "sort_by" ] ++
                        List.indexedMap (renderSortByMetrics user model)
                            [ Metrics.PaymentsAmount
                            , Metrics.DepositsAmount
                            , Metrics.CashoutsAmount
                            , Metrics.NetgamingAmount
                            , Metrics.BetsAmount
                            , Metrics.WinsAmount
                            , Metrics.FirstDepositsAmount
                            ]
                    ]
                , cell [ size Desktop 4, size Tablet 3, size Phone 12 ]
                    [ span []
                        <| [ text <| translate model.locale <| Dashboard "period" ] ++
                        List.indexedMap (renderCurrentPeriod user model)
                            [ ("month", "period_month")
                            , ("year", "period_year")
                            , ("days30", "period_days30")
                            , ("months12", "period_months12")
                            ]
                    ]
                , cell [ size Desktop 4, size Tablet 2, size Phone 12 ]
                    [ span [] [ renderPreviousPeriods user model ]
                    ]
                , cell [ size All 12, Elevation.e4 ]
                    [ renderTotal user model maximumValue
                    ] -- ++ List.map (renderProject user model maximumValue) model.dashboard.projects
                ]
            ]

renderTotal : CurrentUser -> Model -> Float -> Html Messages.Msg
renderTotal user model maximumValue =
    let
        totals = model.dashboard.totals
        totalCharts = model.dashboard.charts.totals
    in
        div []
            [ grid []
                [ cell [ Typography.display1, size All 12 ]
                    [ text <| translate model.locale <| Dashboard "total" ]
                , cell [ size Desktop 4, size Tablet 3, size Phone 12 ]
                    [ renderTotalProgress user model totals maximumValue
                    , renderTotalCharts user model totalCharts
                    ]
                , cell [ size Desktop 8, size Tablet 5, size Phone 12 ]
                    [ div [] [ text "Consolidated table" ]
                    ]
                ]
            ]

--renderProject : CurrentUser -> Model -> Float -> Project -> Html Messages.Msg
--renderProject user model maximumValue project =
--    let
--        maybeStats = Array.filter (\v -> v.id == project.id) model.dashboard.stats
--        |> Array.get 0
--        stats = case maybeStats of
--            Nothing -> {id = project.id, values = Array.empty}
--            Just value -> value
--        --statCharts = model.dashboard.charts.stats
--    in
--        div []
--            [ grid []
--                [ cell [ Typography.display1, size All 12 ]
--                    [ text <| project.title ]
--                , cell [ size Desktop 4, size Tablet 3, size Phone 12 ]
--                    []
--                    --[ renderProjectProgress user model stats maximumValue
--                    --, renderProjectCharts user model project statCharts
--                    --]
--                , cell [ size Desktop 8, size Tablet 5, size Phone 12 ]
--                    [ div [] [ text "Consolidated table" ]
--                    ]
--                ]
--            ]

renderTotalProgress : CurrentUser -> Model -> TotalStats -> Float -> Html Messages.Msg
renderTotalProgress user model stats maximumValue =
    let
        periods = model.dashboard.periods
        metrics = Metrics.stringToType user.settings.dashboardSort
        currentValue = getStatValue metrics stats.current
        comparisonValue = getStatValue metrics stats.comparison
        currentProgress = if maximumValue == 0 then 0 else currentValue / maximumValue * 100
        comparisonProgress = if maximumValue == 0 then 0 else comparisonValue / maximumValue * 100
    in
        grid
            [ Options.css "padding-top" "0px"
            , Options.css "padding-bottom" "0px"
            ]
            [ cell
                [ Typography.subhead
                , size All 6
                , Options.css "margin-top" "0px"
                , Options.css "margin-bottom" "0px"
                ]
                [ text <| formatPeriod (Array.get 0 periods.current) user model True ]
            , cell
                [ Typography.title
                , size All 6
                , Typography.right
                , Options.css "margin-top" "0px"
                , Options.css "margin-bottom" "0px"
                ]
                [ text <| formatMetricsValue metrics currentValue ]
            , cell
                [ size All 12
                , Options.css "margin-top" "0px"
                , Options.css "margin-bottom" "0px"
                ]
                [ Progress.progress currentProgress ]
            , cell
                [ size All 12
                , Options.css "margin-top" "0px"
                ]
                [ delta currentValue comparisonValue metrics ]
            , cell
                [ Typography.subhead
                , size All 6
                , Options.css "margin-top" "0px"
                , Options.css "margin-bottom" "0px"
                ]
                [ text <| formatPeriod (Array.get 0 periods.comparison) user model False ]
            , cell
                [ Typography.title
                , size All 6
                , Typography.right
                , Options.css "margin-top" "0px"
                , Options.css "margin-bottom" "0px"
                ]
                [ text <| formatMetricsValue metrics comparisonValue ]
            , cell
                [ size All 12
                , Options.css "margin-top" "0px"
                , Options.css "margin-bottom" "0px"
                ]
                [ Progress.progress comparisonProgress ]
            ]

--renderProjectProgress : CurrentUser -> Model -> TotalStats -> Float -> Html Messages.Msg
--renderProjectProgress user model stats maximumValue =
--    let
--        periods = model.dashboard.periods
--        metrics = Metrics.stringToType user.settings.dashboardSort
--        currentValue = getStatValue metrics stats.current
--        comparisonValue = getStatValue metrics stats.comparison
--        currentProgress = if maximumValue == 0 then 0 else currentValue / maximumValue * 100
--        comparisonProgress = if maximumValue == 0 then 0 else comparisonValue / maximumValue * 100
--    in
--        grid
--            [ Options.css "padding-top" "0px"
--            , Options.css "padding-bottom" "0px"
--            ]
--            [ cell
--                [ Typography.subhead
--                , size All 6
--                , Options.css "margin-top" "0px"
--                , Options.css "margin-bottom" "0px"
--                ]
--                [ text <| formatPeriod (Array.get 0 periods.current) user model True ]
--            , cell
--                [ Typography.title
--                , size All 6
--                , Typography.right
--                , Options.css "margin-top" "0px"
--                , Options.css "margin-bottom" "0px"
--                ]
--                [ text <| formatMetricsValue metrics currentValue ]
--            , cell
--                [ size All 12
--                , Options.css "margin-top" "0px"
--                , Options.css "margin-bottom" "0px"
--                ]
--                [ Progress.progress currentProgress ]
--            , cell
--                [ size All 12
--                , Options.css "margin-top" "0px"
--                ]
--                [ delta currentValue comparisonValue metrics ]
--            , cell
--                [ Typography.subhead
--                , size All 6
--                , Options.css "margin-top" "0px"
--                , Options.css "margin-bottom" "0px"
--                ]
--                [ text <| formatPeriod (Array.get 0 periods.comparison) user model False ]
--            , cell
--                [ Typography.title
--                , size All 6
--                , Typography.right
--                , Options.css "margin-top" "0px"
--                , Options.css "margin-bottom" "0px"
--                ]
--                [ text <| formatMetricsValue metrics comparisonValue ]
--            , cell
--                [ size All 12
--                , Options.css "margin-top" "0px"
--                , Options.css "margin-bottom" "0px"
--                ]
--                [ Progress.progress comparisonProgress ]
--            ]


renderTotalCharts : CurrentUser -> Model -> DashboardChartTotalsData -> Html Messages.Msg
renderTotalCharts user model charts =
    let
        dailyStats = model.dashboard.charts.totals.daily
        monthlyStats = model.dashboard.charts.totals.monthly
        dailyTooltip metrics = areaChartTooltip model metrics Nothing dailyStats
        monthlyTooltip metrics = barChartTooltip model metrics Nothing monthlyStats
        labelStyle = [ style [ ("height", "20px") ] ]
        blockLabel key = translate model.locale (Dashboard key)
    in
        grid
            [ Options.css "padding-top" "0px"
            , Options.css "padding-bottom" "0px"
            ]
            [ cell [ size All 12 ]
                [ Tabs.render Mdl [10] model.mdl
                    [ Tabs.onSelectTab <| DashboardMsg << SetActiveTab
                    , Tabs.activeTab model.dashboard.activeTab
                    ]
                    [ Tabs.label
                        [ Options.center
                        , Options.css "cursor" "pointer"
                        , Options.css "width" "100%"
                        ]
                        [ Options.span [ Options.css "width" "4px" ] []
                        , text <| translate model.locale <| Dashboard "inout"
                        ]
                    , Tabs.label
                        [ Options.center
                        , Options.css "cursor" "pointer"
                        , Options.css "width" "100%"
                        ]
                        [ Options.span [ Options.css "width" "4px" ] []
                        , text <| translate model.locale <| Dashboard "netgaming"
                        ]
                    ]
                    <| case model.dashboard.activeTab of
                        0 ->
                            [ div labelStyle
                                [ span
                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.PaymentsAmount), ("margin-right", "10px") ] ]
                                    [ text <| blockLabel "inout" ]
                                , span
                                    []
                                    [ text <| dailyTooltip Metrics.PaymentsAmount ++ monthlyTooltip Metrics.PaymentsAmount ]
                                ]
                            , div []
                                [ areaChart user model Metrics.PaymentsAmount Nothing dailyStats
                                , barChart user model Metrics.PaymentsAmount Nothing monthlyStats
                                ]
                            , div labelStyle
                                [ span
                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.DepositsAmount), ("margin-right", "10px") ] ]
                                    [ text <| blockLabel "deposits" ]
                                , span
                                    []
                                    [ text <| dailyTooltip Metrics.DepositsAmount ++ monthlyTooltip Metrics.DepositsAmount ]
                                ]
                            , div []
                                [ areaChart user model Metrics.DepositsAmount Nothing dailyStats
                                , barChart user model Metrics.DepositsAmount Nothing monthlyStats
                                ]
                            , div labelStyle
                                [ span
                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.CashoutsAmount), ("margin-right", "10px") ] ]
                                    [ text <| blockLabel "withdrawal" ]
                                , span
                                    []
                                    [ text <| dailyTooltip Metrics.CashoutsAmount ++ monthlyTooltip Metrics.CashoutsAmount ]
                                ]
                            , div []
                                [ areaChart user model Metrics.CashoutsAmount Nothing dailyStats
                                , barChart user model Metrics.CashoutsAmount Nothing monthlyStats
                                ]
                            ]
                        _ ->
                            [ div labelStyle
                                [ span
                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.NetgamingAmount), ("margin-right", "10px") ] ]
                                    [ text <| blockLabel "netgaming" ]
                                , span
                                    []
                                    [ text <| dailyTooltip Metrics.NetgamingAmount ++ monthlyTooltip Metrics.NetgamingAmount ]
                                ]
                            , div []
                                [ areaChart user model Metrics.NetgamingAmount Nothing dailyStats
                                , barChart user model Metrics.NetgamingAmount Nothing monthlyStats
                                ]
                            , div labelStyle
                                [ span
                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.BetsAmount), ("margin-right", "10px") ] ]
                                    [ text <| blockLabel "bets" ]
                                , span
                                    []
                                    [ text <| dailyTooltip Metrics.BetsAmount ++ monthlyTooltip Metrics.BetsAmount ]
                                ]
                            , div []
                                [ areaChart user model Metrics.BetsAmount Nothing dailyStats
                                , barChart user model Metrics.BetsAmount Nothing monthlyStats
                                ]
                            , div labelStyle
                                [ span
                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.WinsAmount), ("margin-right", "10px") ] ]
                                    [ text <| blockLabel "wins" ]
                                , span
                                    []
                                    [ text <| dailyTooltip Metrics.WinsAmount ++ monthlyTooltip Metrics.WinsAmount ]
                                ]
                            , div []
                                [ areaChart user model Metrics.WinsAmount Nothing dailyStats
                                , barChart user model Metrics.WinsAmount Nothing monthlyStats
                                ]
                            ]
                ]
            ]

--renderProjectCharts : CurrentUser -> Model -> String -> DashboardChartStatsData -> Html Messages.Msg
--renderProjectCharts user model project charts =
--    let
--        dailyStats = Array.filter (\projectStats -> projectStats.project == project) model.dashboard.charts.stats.daily
--        monthlyStats = model.dashboard.charts.stats.monthly
--        dailyTooltip metrics = areaChartTooltip model metrics Nothing dailyStats
--        monthlyTooltip metrics = barChartTooltip model metrics Nothing monthlyStats
--        labelStyle = [ style [ ("height", "20px") ] ]
--        blockLabel key = translate model.locale (Dashboard key)
--    in
--        grid
--            [ Options.css "padding-top" "0px"
--            , Options.css "padding-bottom" "0px"
--            ]
--            [ cell [ size All 12 ]
--                [ Tabs.render Mdl [10] model.mdl
--                    [ Tabs.onSelectTab <| DashboardMsg << SetActiveTab
--                    , Tabs.activeTab model.dashboard.activeTab
--                    ]
--                    [ Tabs.label
--                        [ Options.center
--                        , Options.css "cursor" "pointer"
--                        , Options.css "width" "100%"
--                        ]
--                        [ Options.span [ Options.css "width" "4px" ] []
--                        , text <| translate model.locale <| Dashboard "inout"
--                        ]
--                    , Tabs.label
--                        [ Options.center
--                        , Options.css "cursor" "pointer"
--                        , Options.css "width" "100%"
--                        ]
--                        [ Options.span [ Options.css "width" "4px" ] []
--                        , text <| translate model.locale <| Dashboard "netgaming"
--                        ]
--                    ]
--                    <| case model.dashboard.activeTab of
--                        0 ->
--                            [ div labelStyle
--                                [ span
--                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.PaymentsAmount), ("margin-right", "10px") ] ]
--                                    [ text <| blockLabel "inout" ]
--                                , span
--                                    []
--                                    [ text <| dailyTooltip Metrics.PaymentsAmount ++ monthlyTooltip Metrics.PaymentsAmount ]
--                                ]
--                            , div []
--                                [ areaChart user model Metrics.PaymentsAmount Nothing dailyStats
--                                , barChart user model Metrics.PaymentsAmount Nothing monthlyStats
--                                ]
--                            , div labelStyle
--                                [ span
--                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.DepositsAmount), ("margin-right", "10px") ] ]
--                                    [ text <| blockLabel "deposits" ]
--                                , span
--                                    []
--                                    [ text <| dailyTooltip Metrics.DepositsAmount ++ monthlyTooltip Metrics.DepositsAmount ]
--                                ]
--                            , div []
--                                [ areaChart user model Metrics.DepositsAmount Nothing dailyStats
--                                , barChart user model Metrics.DepositsAmount Nothing monthlyStats
--                                ]
--                            , div labelStyle
--                                [ span
--                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.CashoutsAmount), ("margin-right", "10px") ] ]
--                                    [ text <| blockLabel "withdrawal" ]
--                                , span
--                                    []
--                                    [ text <| dailyTooltip Metrics.CashoutsAmount ++ monthlyTooltip Metrics.CashoutsAmount ]
--                                ]
--                            , div []
--                                [ areaChart user model Metrics.CashoutsAmount Nothing dailyStats
--                                , barChart user model Metrics.CashoutsAmount Nothing monthlyStats
--                                ]
--                            ]
--                        _ ->
--                            [ div labelStyle
--                                [ span
--                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.NetgamingAmount), ("margin-right", "10px") ] ]
--                                    [ text <| blockLabel "netgaming" ]
--                                , span
--                                    []
--                                    [ text <| dailyTooltip Metrics.NetgamingAmount ++ monthlyTooltip Metrics.NetgamingAmount ]
--                                ]
--                            , div []
--                                [ areaChart user model Metrics.NetgamingAmount Nothing dailyStats
--                                , barChart user model Metrics.NetgamingAmount Nothing monthlyStats
--                                ]
--                            , div labelStyle
--                                [ span
--                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.BetsAmount), ("margin-right", "10px") ] ]
--                                    [ text <| blockLabel "bets" ]
--                                , span
--                                    []
--                                    [ text <| dailyTooltip Metrics.BetsAmount ++ monthlyTooltip Metrics.BetsAmount ]
--                                ]
--                            , div []
--                                [ areaChart user model Metrics.BetsAmount Nothing dailyStats
--                                , barChart user model Metrics.BetsAmount Nothing monthlyStats
--                                ]
--                            , div labelStyle
--                                [ span
--                                    [ style [ ("color", rgbaToString <| dashboardMetricsColor Metrics.WinsAmount), ("margin-right", "10px") ] ]
--                                    [ text <| blockLabel "wins" ]
--                                , span
--                                    []
--                                    [ text <| dailyTooltip Metrics.WinsAmount ++ monthlyTooltip Metrics.WinsAmount ]
--                                ]
--                            , div []
--                                [ areaChart user model Metrics.WinsAmount Nothing dailyStats
--                                , barChart user model Metrics.WinsAmount Nothing monthlyStats
--                                ]
--                            ]
--                ]
--            ]

formatPeriod : Maybe String -> CurrentUser -> Model -> Bool -> String
formatPeriod maybePeriod user model isCurrent =
        case maybePeriod of
            Nothing -> ""
            Just period ->
                let
                    date = dateFromMonthString period
                in
                    case user.settings.dashboardPeriod of
                        "month" -> format (getDateConfig model.locale) monthFormat date
                        "year" -> format (getDateConfig model.locale) yearFormat date
                        "days30" -> translate model.locale <| Dashboard <| if isCurrent then "current" else "previous"
                        _ -> translate model.locale <| Dashboard <| if isCurrent then "current" else "previous"

getSortedStats : Metrics.Metrics -> Array ProjectStats -> Array ProjectStats
getSortedStats metrics stats =
    Array.toList stats
    |> List.sortWith
        (\a b ->
            let
                getMaxValue v = case v of
                    Nothing -> 0.0
                    Just v -> v
                maxA = List.map (getStatValue metrics) [ a.values.current, a.values.comparison ]
                |> List.maximum
                |> getMaxValue
                maxB = List.map (getStatValue metrics) [ b.values.current, b.values.comparison ]
                |> List.maximum
                |> getMaxValue
            in
                case compare maxA maxB of
                    LT -> GT
                    EQ -> EQ
                    GT -> LT
        )
    |> Array.fromList

getMaximumStatsValue : Metrics.Metrics -> TotalStats -> Array ProjectStats -> Float
getMaximumStatsValue metrics totals sortedStats =
    let
        totalValues =
            [ getStatValue metrics totals.current, getStatValue metrics totals.comparison ]
        statsValues =
            Array.map (\v -> [ v.values.current, v.values.comparison ]) sortedStats
            |> Array.toList
            |> List.concat
            |> List.map (getStatValue metrics)
        maximum = List.maximum (totalValues)
    in
        case maximum of
            Nothing -> 0.0
            Just v -> v

renderCurrentPeriod : CurrentUser -> Model -> Int -> (String, String) -> Html Messages.Msg
renderCurrentPeriod user model i (period, translationId) =
    Toggles.radio Mdl [i + 10] model.mdl
        [ Toggles.value <| user.settings.dashboardPeriod == period
        , Toggles.group "CurrentPeriod"
        , Options.css "display" "block"
        , Toggles.onClick <| DashboardMsg <| DashboardMessages.SetDashboardCurrentPeriod period
        ]
        [ text <| translate model.locale <| Dashboard <| "period_" ++ period ]

renderPreviousPeriods : CurrentUser -> Model -> Html Messages.Msg
renderPreviousPeriods user model =
    case user.settings.dashboardPeriod of
        "month" ->
            div []
                <| [ text <| translate model.locale <| Dashboard "compare_period" ] ++
                    List.map (renderComparePeriod user model) [1..6]
        _ ->
            div [] []

renderComparePeriod : CurrentUser -> Model -> Int -> Html Messages.Msg
renderComparePeriod user model i =
    let
        value = negate i
        date = Duration.add Duration.Month value model.currentDate
        formattedDate = format (getDateConfig model.locale) "%b %Y" date
    in
        Toggles.radio Mdl [i + 20] model.mdl
            [ Toggles.value <| user.settings.dashboardComparePeriod == value
            , Toggles.group "ComparePeriod"
            , Options.css "display" "block"
            , Toggles.onClick <| DashboardMsg <| DashboardMessages.SetDashboardComparisonPeriod value
            ]
            [ text formattedDate ]

renderSortByMetrics : CurrentUser -> Model -> Int -> Metrics.Metrics -> Html Messages.Msg
renderSortByMetrics user model i metrics =
    Toggles.radio Mdl [i + 2] model.mdl
        [ Toggles.value <| (Metrics.stringToType user.settings.dashboardSort) == metrics
        , Toggles.group "SortBy"
        , Options.css "display" "block"
        , Toggles.onClick <| DashboardMsg <| DashboardMessages.SetDashboardSort metrics
        ]
        [ text <| translate model.locale <| Dashboard <| "sort_by_" ++ (Metrics.typeToString metrics) ]

projectProps : CurrentUser -> String -> List (Button.Property Messages.Msg)
projectProps user buttonType =
    let
        initialProps =
            [ Button.raised
            , Button.ripple
            , Button.onClick <| DashboardMsg <| DashboardMessages.SetDashboardProjectsType buttonType
            , Options.css "margin" "0 6px"
            ]
    in
        if user.settings.dashboardProjectsType == buttonType then
            initialProps ++ [Button.primary]
        else
            initialProps
