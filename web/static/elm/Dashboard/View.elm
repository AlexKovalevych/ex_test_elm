module Dashboard.View exposing (..)

import Array
import Auth.Models exposing (CurrentUser)
import Dashboard.Messages as DashboardMessages exposing (Msg(..), OutMsg(..))
import Date
import Date.Extra.Duration as Duration
import Date.Extra.Format exposing (format)
import Html exposing (..)
import Material.Button as Button
import Material.Elevation as Elevation
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Options as Options
import Material.Toggles as Toggles
import Material.Typography as Typography
import Messages exposing (..)
import Models exposing (..)
import Translation exposing (..)
import String
import Date.GtDate exposing (dateFromMonthString)

view : Model -> CurrentUser -> Html Messages.Msg
view model user =
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
                [ renderTotal user model
                ]
            ]
        ]

renderTotal : CurrentUser -> Model -> Html Messages.Msg
renderTotal user model =
    div []
        [ Options.styled div
            [ Typography.display1 ]
            [ text <| translate model.locale <| Dashboard "total" ]
        , grid []
            [ cell [ size Desktop 6, size Tablet 4, size Phone 12 ]
                [ div []
                    [ Options.styled div [ Typography.subhead ]
                        [ text <| formatPeriod (Array.get 0 model.dashboard.periods.current) user model ]
                    --, Options.styled div [ Typography.title ]
                    --    [ text  ]
                    ]
                , div [] [ text "Charts" ]
                ]
            , cell [ size Desktop 6, size Tablet 4, size Phone 12 ]
                [ div [] [ text "Consolidated table" ]
                ]
            ]
        ]

        --<Subheader>Total</Subheader>
        --<div className='row'>
        --    <div className='col-lg-4 col-md-4 col-xs-12'>
        --        <DashboardProgress
        --            sortBy={this.props.user.settings.dashboardSort}
        --            periods={this.props.data.periods}
        --            stats={this.props.data.totals}
        --            periodType={this.props.user.settings.dashboardPeriod}
        --            maximumValue={maximumValue}
        --        />
        --        {
        --            this.props.data.charts && (
        --                <DashboardCharts stats={this.props.data.charts.totals} />
        --            )
        --        }
        --    </div>
        --    <div className='col-lg-8 col-md-8 col-xs-12'>
        --        <ConsolidatedTable
        --            periodType={this.props.user.settings.dashboardPeriod}
        --            periods={this.props.data.periods}
        --            stats={this.props.data.totals}
        --            chart={this.props.data.consolidatedChart}
        --        />
        --    </div>
        --</div>

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

renderProgress user periods stats maximumValue =
    div []
        [ div [] [ periods.current ]
        ]
            --<div style={{padding: gtTheme.theme.appBar.padding}}>
            --    <div className="row between-xs">
            --        <div className="col-xs-6">
            --            <div className="box">
            --                {formatter.formatDashboardPeriod(this.props.periodType, this.props.periods.current[0], 'current')}
            --            </div>
            --        </div>
            --        <div className="col-xs-6 end-xs">
            --            <div className="box">
            --                {formatter.formatValue(currentValue, sortBy)}
            --            </div>
            --        </div>
            --        <LinearProgress
            --            color={colorManager.getChartColor(sortBy)}
            --            mode="determinate"
            --            value={currentValue / this.props.maximumValue * 100}
            --        />
            --    </div>
            --    <Delta value={formatter.formatValue(currentValue - comparisonValue, sortBy)} />
            --    <span> (<Delta value={`${comparisonValue == 0 ? 0 : Math.round(currentValue / comparisonValue * 100) - 100}%`} />)</span>
            --    <div className="row between-xs" style={{paddingTop: gtTheme.theme.padding.sm}}>
            --        <div className="col-xs-6">
            --            <div className="box">
            --                {formatter.formatDashboardPeriod(this.props.periodType, this.props.periods.comparison[0], 'previous')}
            --            </div>
            --        </div>
            --        <div className="col-xs-6 end-xs">
            --            <div className="box">
            --                {formatter.formatValue(comparisonValue, sortBy)}
            --            </div>
            --        </div>
            --        <LinearProgress
            --            color={gtTheme.theme.palette.disabledColor}
            --            mode="determinate"
            --            value={comparisonValue / this.props.maximumValue * 100}
            --        />
            --    </div>
            --</div>

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
