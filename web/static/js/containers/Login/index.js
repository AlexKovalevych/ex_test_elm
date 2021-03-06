import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import authActions from 'actions/auth';
import { IndexLink } from 'react-router';
import Divider from 'material-ui/Divider';
import Paper from 'material-ui/Paper';
import TextField from 'material-ui/TextField';
import RaisedButton from 'material-ui/RaisedButton';
import Translate from 'react-translate-component';
import counterpart from 'counterpart';
import moment from 'moment';
import formatter from 'managers/Formatter';

const styles = {
    button: {
        margin: '20px'
    },
    paper: {
        padding: '0 20px'
    },
    form: {
        textAlign: 'center'
    }
};

class Login extends React.Component {
    static propTypes = {
        user: PropTypes.object,
        dispatch: PropTypes.func,
        smsSent: PropTypes.bool,
        error: PropTypes.string,
        qrcodeUrl: PropTypes.string,
        serverTime: PropTypes.number
    };

    static contextTypes = {
        router: PropTypes.object.isRequired
    }

    constructor(props) {
        super(props);
        this.state = {
            code: null,
            serverTime: null
        };
    }

    resetError() {
        this.props.dispatch({
            type: 'AUTH_LOGIN_ERROR',
            value: false
        });
    }

    componentDidMount() {
        this.resetError();
    }

    componentWillReceiveProps(newProps) {
        let component = this;
        if (newProps.serverTime && !this.state.serverTime) {
            this.serverTimeInterval = window.setInterval(() => {
                let serverTime = component.state.serverTime.clone().add(1, 's');
                component.setState({serverTime});
            }, 1000);
            this.setState({serverTime: moment(newProps.serverTime)});
        }
    }

    componentWillUnmount() {
        clearInterval(this.serverTimeInterval);
    }

    onSubmit(e) {
        e.preventDefault();
        const { email, password } = this.refs;
        const { dispatch } = this.props;
        const params = {email: email.input.value, password: password.input.value};
        dispatch(authActions.login(params));
    }

    onResendSms(e) {
        e.preventDefault();
        const { dispatch } = this.props;
        dispatch(authActions.sendSms());
    }

    onTwoFactorSubmit(e) {
        e.preventDefault();
        const { twoFactor } = this.refs;
        const { dispatch } = this.props;
        dispatch(authActions.twoFactor(twoFactor.input.value));
    }

    onChangeCode(e) {
        this.setState({code: e.target.value});
    }

    render() {
        let error;
        if (this.props.error) {
            error = (<Translate content={this.props.error} />);
        }
        counterpart.setLocale('ru');

        let form;
        if (this.props.user && this.props.user.enabled) {
            switch (this.props.user.authenticationType) {
            case 'sms':
                form = (
                    <form onSubmit={this.onTwoFactorSubmit.bind(this)}>
                        <div style={{padding: 16}}>
                            <Translate content="login.sms_sent" phone={this.props.user.securePhoneNumber} />
                        </div>
                        <Divider />
                        <TextField
                            hintText={<Translate content="form.sms_code" />}
                            floatingLabelText={<Translate content="form.sms_code" />}
                            ref="twoFactor"
                            id="twoFactor"
                            underlineShow={false}
                            fullWidth={true}
                            errorText={error}
                        />
                        <div>
                            {
                                this.props.smsSent && (
                                    <h6 style={{margin: 0}}>
                                        <Translate content="login.sms_was_sent" />
                                    </h6>
                                )
                            }
                            <RaisedButton
                                type="submit"
                                label={<Translate content="form.login" />}
                                primary={true}
                                style={styles.button}
                            />
                            <RaisedButton
                                label={<Translate content="form.sms_resend" />}
                                style={styles.button}
                                onMouseUp={this.onResendSms.bind(this)}
                            />
                        </div>
                    </form>
                );
                break;
            case 'google':
                form = (
                    <form onSubmit={this.onTwoFactorSubmit.bind(this)}>
                        <div>
                            <img src={this.props.qrcodeUrl} />
                        </div>
                        <div>
                            <Translate content="login.server_time" />
                            <b>{formatter.formatDaytime(this.state.serverTime)}</b>
                        </div>
                        <TextField
                            onChange={this.onChangeCode.bind(this)}
                            hintText={<Translate content="form.google_code" />}
                            ref="twoFactor"
                            id="twoFactor"
                            underlineShow={false}
                            fullWidth={true}
                            errorText={error}
                        />
                        <div>
                            <RaisedButton
                                type="submit"
                                label={<Translate content="form.login" />}
                                primary={true}
                                style={styles.button}
                            />
                        </div>
                    </form>
                );
                break;
            }
        } else {
            form = (
                <form onSubmit={this.onSubmit.bind(this)}>
                    <TextField
                        hintText={<Translate content="form.email" />}
                        ref="email"
                        id="email"
                        underlineShow={false}
                        fullWidth={true}
                        errorText={error}
                    />
                    <Divider />
                    <TextField
                        key="password"
                        type="password"
                        ref="password"
                        id="password"
                        hintText={<Translate content="form.password" />}
                        underlineShow={false}
                        fullWidth={true}
                    />
                    <Divider />
                    <div>
                        <RaisedButton
                            type="submit"
                            label={<Translate content="form.login" />}
                            primary={true}
                            style={styles.button}
                        />
                    </div>
                </form>
            );
        }

        return (
            <div className="row">
                <div className="col-xs-offset-4 col-xs-4" style={styles.form}>
                    <IndexLink to="/">
                        <img src="/images/logo.png" alt="logo" />
                    </IndexLink>
                    <Paper zDepth={2} style={styles.paper}>{form}</Paper>
                </div>
                {
                    this.props.user &&
                    this.props.user.enabled &&
                    this.props.user.authenticationType == 'google' &&
                    (
                        <div style={{margin: '20px auto'}}>
                            <a
                                className='storeLink'
                                target="_blank"
                                href="https://itunes.apple.com/ua/app/google-authenticator/id388497605?mt=8"
                            >
                                <img src="/images/button_app_store.png" width="150" height="44" />
                            </a>
                            <a
                                className='storeLink'
                                target="_blank"
                                href="http://apps.microsoft.com/windows/en-us/app/google-authenticator/7ea6de74-dddb-47df-92cb-40afac4d38bb"
                            >
                                <img src="/images/button_windows_store.png" width="150" height="44" />
                            </a>
                            <a
                                className='storeLink'
                                target="_blank"
                                href="https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2"
                            >
                                <img src="/images/button_play_store.png" width="150" height="44" />
                            </a>
                        </div>
                    )
                }
            </div>
        );
    }
}

const mapStateToProps = (state) => {
    return state.auth;
};

export default connect(mapStateToProps)(Login);
