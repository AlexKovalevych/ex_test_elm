module Dashboard.View exposing (..)

import Auth.Models exposing (CurrentUser)
import Material.Button as Button
import Material.Options as Options
import Material.Typography as Typography
import Messages exposing (..)
import Dashboard.Messages as DashboardMessages exposing (Msg(..), OutMsg(..))
import Models exposing (..)
import Html exposing (..)
import Translation exposing (..)
--import Socket.Messages as SocketMessages exposing (PushModel, InternalMsg(PushMessage, DecodeCurrentUser))
--import Json.Encode as JE

view : Model -> CurrentUser -> Html Messages.Msg
view model user =
    div []
        [ Options.styled div
            [ Typography.subhead ]
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
        ]

projectProps : CurrentUser -> String -> List (Button.Property Messages.Msg)
projectProps user buttonType =
    let
        initialProps =
            [ Button.raised
            , Button.ripple
            , Button.onClick <| DashboardMsg <| DashboardMessages.SetDashboardProjectsType buttonType
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
