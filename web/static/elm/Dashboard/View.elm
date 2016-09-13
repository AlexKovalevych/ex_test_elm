module Dashboard.View exposing (..)

import Auth.Models exposing (CurrentUser)
import Material.Button as Button
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Options as Options
import Material.Toggles as Toggles
import Material.Typography as Typography
import Messages exposing (..)
import Dashboard.Messages as DashboardMessages exposing (Msg(..), OutMsg(..))
import Models exposing (..)
import Html exposing (..)
import Translation exposing (..)
import Date.Extra.Duration as Duration
import Date.Extra.Format exposing (format)
import Date
import Result

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
            , cell [ size Desktop 4, size Tablet 4, size Phone 12 ]
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
            , cell [ size Desktop 4, size Tablet 4, size Phone 12 ]
                [ span []
                    <| List.indexedMap (renderCurrentPeriod user model)
                        [ ("month", "period_month")
                        , ("year", "period_year")
                        , ("days30", "period_days30")
                        , ("months12", "period_months12")
                        ] ++ [ renderPreviousPeriods user model ]

                    --[
                    --text <| translate model.locale <| Dashboard "current_period"
                    --Button.render Mdl [10] model.mdl
                    --    (periodProps user "month")
                    --    [ text <| translate model.locale <| Dashboard "period_month" ]
                    --, Button.render Mdl [10] model.mdl
                    --    (periodProps user "year")
                    --    [ text <| translate model.locale <| Dashboard "period_year" ]
                    --, Button.render Mdl [11] model.mdl
                    --    (periodProps user "days30")
                    --    [ text <| translate model.locale <| Dashboard "period_days30" ]
                    --, Button.render Mdl [11] model.mdl
                    --    (periodProps user "months12")
                    --    [ text <| translate model.locale <| Dashboard "period_months12" ]
                    --]
                ]
            ]
        ]

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
                    List.indexedMap (renderComparePeriod user model) [1..6]
        _ -> ""

renderComparePeriod : CurrentUser -> Model -> Int -> Html Messages.Msg
renderComparePeriod user model i =
    let
        value = negate i
        --now = Date.fromString model.dashboard.periods.current
        --date = Duration.add Duration.Month value
        formattedDate = format (getDateConfig model.locale) "%b:%Y" date
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

            --<div>
            --    <div className="row">
            --        {title}
            --        <div className="col-lg-8 col-md-8 col-xs-12">
            --            <div className="end-xs">
            --                <span style={{marginRight: 12}}>
            --                    <Translate content="dashboard.project_types" />
            --                    <RaisedButton
            --                        label={<Translate content="dashboard.projects.default" />}
            --                        primary={projectsType == 'default'}
            --                        style={styles}
            --                        onClick={this.onChangeProjectsType.bind(this, 'default')}
            --                    />
            --                    <RaisedButton
            --                        label={<Translate content="dashboard.projects.partner" />}
            --                        primary={projectsType == 'partner'}
            --                        style={styles}
            --                        onClick={this.onChangeProjectsType.bind(this, 'partner')}
            --                    />
            --                </span>
            --                <SelectField
            --                    id="sortByMetrics"
            --                    value={this.props.user.settings.dashboardSort}
            --                    onChange={this.onChangeSortMetrics.bind(this)}
            --                    floatingLabelText={<Translate content="dashboard.sort_by_metrics" />}
            --                    style={{textAlign: 'left'}}
            --                >
            --                    <MenuItem value="paymentsAmount" primaryText={<Translate content="dashboard.sort_by.paymentsAmount" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="depositsAmount" primaryText={<Translate content="dashboard.sort_by.depositsAmount" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="cashoutsAmount" primaryText={<Translate content="dashboard.sort_by.cashoutsAmount" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="netgamingAmount" primaryText={<Translate content="dashboard.sort_by.netgamingAmount" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="betsAmount" primaryText={<Translate content="dashboard.sort_by.betsAmount" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="winsAmount" primaryText={<Translate content="dashboard.sort_by.winsAmount" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="firstDepositsAmount" primaryText={<Translate content="dashboard.sort_by.firstDepositsAmount" />} style={gtTheme.theme.link} />
            --                </SelectField>
            --            </div>
            --            <div className="end-xs">
            --                <SelectField
            --                    id="currentPeriod"
            --                    value={this.props.user.settings.dashboardPeriod}
            --                    onChange={this.onChangeCurrentPeriod.bind(this)}
            --                    floatingLabelText={<Translate content="dashboard.current_period" />}
            --                    style={{textAlign: 'left'}}
            --                >
            --                    <MenuItem value="month" primaryText={<Translate content="dashboard.period.month" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="year" primaryText={<Translate content="dashboard.period.year" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="days30" primaryText={<Translate content="dashboard.period.last_30_days" />} style={gtTheme.theme.link} />
            --                    <MenuItem value="months12" primaryText={<Translate content="dashboard.period.last_12_months" />} style={gtTheme.theme.link} />
            --                </SelectField>
            --                {this.getComparisonPeriod()}
            --            </div>
            --        </div>
            --    </div>


    --text "Dashboard here"
