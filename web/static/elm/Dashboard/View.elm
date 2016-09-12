module Dashboard.View exposing (..)

import Models exposing (..)
import Messages exposing (..)
import Html exposing (..)
import Translation exposing (..)

view : Model -> Html Msg
view model =
    --div []
    --    [ div []
    --        [ text <| translate model.locale <| Login "password"
    --        ]
    --    ]


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


    text "Dashboard here"
