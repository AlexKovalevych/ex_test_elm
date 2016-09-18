module Dashboard.View exposing (..)

import Array exposing (..)
import Auth.Models exposing (CurrentUser)
import Dashboard.Messages as DashboardMessages exposing (Msg(..), OutMsg(..), InternalMsg(..))
import Dashboard.Models exposing
    ( DashboardStatValue
    , DashboardPeriods
    , getValueByMetrics
    , TotalStats
    , ProjectStats
    , DashboardChartTotalsData
    )
import Dashboard.View.Delta exposing (delta)
import Date
import Date.GtDate exposing (dateFromMonthString)
import Date.Extra.Duration as Duration
import Date.Extra.Format exposing (format)
import Formatter exposing (formatMetricsValue)
import Html exposing (..)
import Html.Attributes exposing (id, height, style)
import Html.Events exposing (onMouseLeave)
import Material.Button as Button
import Material.Elevation as Elevation
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Options as Options
import Material.Progress as Progress
import Material.Tooltip as Tooltip
import Material.Tabs as Tabs
import Material.Toggles as Toggles
import Material.Typography as Typography
import Messages exposing (..)
import Models exposing (..)
import String
import Translation exposing (..)
import Native.Chart
import Dashboard.View.Spline exposing (..)
import Json.Encode as JE

view : Model -> CurrentUser -> Html Messages.Msg
view model user =
    let
        metrics = user.settings.dashboardSort
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
                            [ "paymentsAmount"
                            , "depositsAmount"
                            , "cashoutsAmount"
                            , "netgamingAmount"
                            , "betsAmount"
                            , "winsAmount"
                            , "firstDepositsAmount"
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
                    ]
                ]
            ]

renderTotal : CurrentUser -> Model -> Float -> Html Messages.Msg
renderTotal user model maximumValue =
    let
        stats = model.dashboard.stats
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

renderTotalProgress : CurrentUser -> Model -> TotalStats -> Float -> Html Messages.Msg
renderTotalProgress user model stats maximumValue =
    let
        periods = model.dashboard.periods
        metrics = user.settings.dashboardSort
        currentValue = getValue metrics stats.current
        comparisonValue = getValue metrics stats.comparison
        currentProgress = if maximumValue == 0 then 0 else currentValue / maximumValue * 100
        comparisonProgress = if maximumValue == 0 then 0 else comparisonValue / maximumValue * 100
    in
        div []
            [ div []
                [ grid []
                    [ cell [ Typography.subhead, size All 6 ]
                        [ text <| formatPeriod (Array.get 0 periods.current) user model ]
                    , cell [ Typography.title, size All 6, Typography.right ]
                        [ text <| formatMetricsValue metrics currentValue ]
                    , cell [ size All 12 ]
                        [ Progress.progress currentProgress ]
                    , cell [ size All 12 ]
                        [ delta currentValue comparisonValue metrics ]
                    , cell [ Typography.subhead, size All 6 ]
                        [ text <| formatPeriod (Array.get 0 periods.comparison) user model ]
                    , cell [ Typography.title, size All 6, Typography.right ]
                        [ text <| formatMetricsValue metrics comparisonValue ]
                    , cell [ size All 12 ]
                        [ Progress.progress comparisonProgress ]
                    ]
                ]
            ]

renderTotalCharts : CurrentUser -> Model -> DashboardChartTotalsData -> Html Messages.Msg
renderTotalCharts user model charts =
    let
        dailyPaymentsId = splineId user "paymentsAmount" Nothing Dashboard.View.Spline.Daily
        dailyPaymentsData = Array.map (dailyChartData "paymentsAmount" >> JE.int) model.dashboard.charts.totals.daily
        |> JE.array
        |> JE.encode 0
        dailyPaymentsChart = Native.Chart.area dailyPaymentsId dailyPaymentsData
        tooltipIndex = if model.dashboard.splineTooltip.canvasId == dailyPaymentsId then
            toString model.dashboard.splineTooltip.index
        else
            ""
    in
        Tabs.render Mdl [10] model.mdl
            [ Tabs.onSelectTab SelectTab
            , Tabs.activeTab model.dashboard.activeTab
            ]
            [ Tabs.label
                [ Options.center ]
                [ Options.span [ Options.css "width" "4px" ] []
                , text "Inout"
                ]
            , Tabs.label
                [ Options.center ]
                [ Options.span [ Options.css "width" "4px" ] []
                , text "Netgaming"
                ]
            ]
            <| case model.dashboard.activeTab of
                0 ->
                    [ div [ style [ ("height", "10px") ] ] [ text tooltipIndex ]
                    , div []
                        [ canvas
                            [ id dailyPaymentsId
                            , height 40
                            , onMouseLeave <| DashboardMsg (SetSplineTooltip {canvasId = "", index = 0})
                            ]
                            []
                        ]
                    ]
                _ -> [ text <| "netgaming charts" ]

formatPeriod : Maybe String -> CurrentUser -> Model -> String
formatPeriod maybePeriod user model =
        case maybePeriod of
            Nothing -> ""
            Just period ->
                let
                    date = dateFromMonthString period
                in
                    case user.settings.dashboardPeriod of
                        "month" -> format (getDateConfig model.locale) "%b %Y" date
                        "year" -> ""
                        "days30" -> ""
                        _ -> ""
                            --Just period -> format (getDateConfig model.locale)

getSortedStats : String -> Array ProjectStats -> Array ProjectStats
getSortedStats metrics stats =
    Array.toList stats
    |> List.sortWith
        (\a b ->
            let
                getMaxValue v = case v of
                    Nothing -> 0.0
                    Just v -> v
                maxA = Array.map (\maybeValue -> getValue metrics maybeValue) a.values
                |> Array.toList
                |> List.maximum
                |> getMaxValue
                maxB = Array.map (\maybeValue -> getValue metrics maybeValue) b.values
                |> Array.toList
                |> List.maximum
                |> getMaxValue
            in
                case compare maxA maxB of
                    LT -> GT
                    EQ -> EQ
                    GT -> LT
        )
    |> Array.fromList

getValue : String -> Maybe DashboardStatValue -> Float
getValue metrics v = case v of
    Nothing -> 0.0
    Just value -> getValueByMetrics metrics value

getMaximumStatsValue : String -> TotalStats -> Array ProjectStats -> Float
getMaximumStatsValue metrics totals sortedStats =
    let
        getValue v = case v of
            Nothing -> 0.0
            Just value -> getValueByMetrics metrics value
        totalValues =
            [ getValue totals.current, getValue totals.comparison ]
        statsValues =
            Array.map (\v -> v.values |> Array.toList) sortedStats
            |> Array.toList
            |> List.concat
            |> List.map getValue
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

renderSortByMetrics : CurrentUser -> Model -> Int -> String -> Html Messages.Msg
renderSortByMetrics user model i metrics =
    Toggles.radio Mdl [i + 2] model.mdl
        [ Toggles.value <| user.settings.dashboardSort == metrics
        , Toggles.group "SortBy"
        , Options.css "display" "block"
        , Toggles.onClick <| DashboardMsg <| DashboardMessages.SetDashboardSort metrics
        ]
        [ text <| translate model.locale <| Dashboard <| "sort_by_" ++ metrics ]

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
