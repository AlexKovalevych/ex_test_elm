module Auth.View exposing (..)

import Html exposing (..)
import Html.App as App
import Material.Elevation as Elevation
import Material.Options as Options
import Auth.Messages as AuthMessages
import Auth.Models exposing (User(Guest, LoggedUser))
import Material.Textfield as Textfield
import Material.Button as Button
import Models exposing (..)
import Html.Events exposing (onSubmit)
import Translation exposing (..)
import Material.Grid exposing (grid, cell, size, offset, Device(..))
import Html.Attributes exposing (style, src, alt, href, target, width, height)
import Messages exposing (..)
import Material.Snackbar as Snackbar

googleAuthLinks : Html Msg
googleAuthLinks =
    div []
    [ a
        [ href "https://itunes.apple.com/ua/app/google-authenticator/id388497605?mt=8"
        , target "_blank"
        ]
        [ img [ src "/images/button_app_store.png", width 150, height 44 ] []
        ]
    , a
        [ href "http://apps.microsoft.com/windows/en-us/app/google-authenticator/7ea6de74-dddb-47df-92cb-40afac4d38bb"
        , target "_blank"
        ]
        [ img [ src "/images/button_windows_store.png", width 150, height 44 ] []
        ]
    , a
        [ href "https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2"
        , target "_blank"
        ]
        [ img [ src "/images/button_play_store.png", width 150, height 44 ] []
        ]
    ]

serverTime : Model -> Int
serverTime model = case model.auth.serverTime of
    Nothing -> 0
    Just time -> time

qrCodeUrl : Model -> String
qrCodeUrl model = case model.auth.qrcodeUrl of
    Nothing -> ""
    Just url -> url

loginForm : Model -> Html Msg
loginForm model =
    case model.auth.user of
        Guest ->
            form
                [ style [ ("padding", "20px") ]
                , onSubmit (AuthMsg AuthMessages.LoginRequest)
                ]
                [ Textfield.render Mdl [0] model.mdl (emailProperties model)
                , Textfield.render Mdl [1] model.mdl
                    [ Textfield.label (translate model.locale Password)
                    , Textfield.password
                    , Textfield.value model.auth.loginFormPassword
                    , Textfield.floatingLabel
                    , Textfield.onInput (AuthMsg << AuthMessages.ChangeLoginPassword)
                    , Options.css "width" "100%"
                    ]
                , Button.render Mdl [2] model.mdl
                    [ Button.raised
                    , Button.ripple
                    , Button.colored
                    ]
                    [ text <| translate model.locale Login ]
                ]
        LoggedUser user ->
            case user.authenticationType of
                "sms" ->
                    form
                        [ onSubmit (AuthMsg AuthMessages.TwoFactor)
                        ]
                        [ div [ style [ ( "padding", "1rem" ) ] ]
                            [ text <| translate model.locale (SmsSent user.securePhoneNumber)
                            , Textfield.render Mdl [0] model.mdl (smsProperties model)
                            , Button.render Mdl [1] model.mdl
                                [ Button.raised
                                , Button.ripple
                                , Button.primary
                                , Button.type' "submit"
                                ]
                                [ text <| translate model.locale Login ]
                            , Button.render Mdl [2] model.mdl
                                [ Button.raised
                                , Button.ripple
                                , Button.onClick (AuthMsg AuthMessages.SendSms)
                                , Button.type' "button"
                                , Options.css "margin-left" "1rem"
                                ]
                                [ text <| translate model.locale ResendSms ]
                            ]
                        ]
                _ ->
                    form
                        [ onSubmit (AuthMsg AuthMessages.TwoFactor)
                        ]
                        [ div []
                            [ img [ src <| qrCodeUrl model ]  []
                            ]
                        , div []
                            [ text <| translate model.locale (ServerTime <| serverTime model)
                            ]
                        , googleAuthLinks
                        ]
        --    <form onSubmit={this.onTwoFactorSubmit.bind(this)}>
        --        <div style={{padding: 16}}>
        --            <Translate content="login.sms_sent" phone={this.props.user.securePhoneNumber} />
        --        </div>
        --        <Divider />
        --        <TextField
        --            hintText={<Translate content="form.sms_code" />}
        --            floatingLabelText={<Translate content="form.sms_code" />}
        --            ref="twoFactor"
        --            id="twoFactor"
        --            underlineShow={false}
        --            fullWidth={true}
        --            errorText={error}
        --        />
        --        <div>
        --            {
        --                this.props.smsSent && (
        --                    <h6 style={{margin: 0}}>
        --                        <Translate content="login.sms_was_sent" />
        --                    </h6>
        --                )
        --            }
        --            <RaisedButton
        --                type="submit"
        --                label={<Translate content="form.login" />}
        --                primary={true}
        --                style={styles.button}
        --            />
        --            <RaisedButton
        --                label={<Translate content="form.sms_resend" />}
        --                style={styles.button}
        --                onMouseUp={this.onResendSms.bind(this)}
        --            />
        --        </div>
        --    </form>
        --else
        --    <form onSubmit={this.onTwoFactorSubmit.bind(this)}>
        --        <div>
        --            <img src={this.props.qrcodeUrl} />
        --        </div>
        --        <div>
        --            <Translate content="login.server_time" />
        --            <b>{formatter.formatDaytime(this.state.serverTime)}</b>
        --        </div>
        --        <TextField
        --            onChange={this.onChangeCode.bind(this)}
        --            hintText={<Translate content="form.google_code" />}
        --            ref="twoFactor"
        --            id="twoFactor"
        --            underlineShow={false}
        --            fullWidth={true}
        --            errorText={error}
        --        />
        --        <div>
        --            <RaisedButton
        --                type="submit"
        --                label={<Translate content="form.login" />}
        --                primary={true}
        --                style={styles.button}
        --            />
        --        </div>
        --    </form>
        --    googleAuthLinks

emailProperties : Model -> List (Textfield.Property Msg)
emailProperties model =
    let
        error = model.auth.loginFormError
        locale = model.locale
        props =
            [ Textfield.label (translate locale Email)
            , Textfield.autofocus
            , Textfield.floatingLabel
            , Textfield.value model.auth.loginFormEmail
            , Textfield.onInput (AuthMsg << AuthMessages.ChangeLoginEmail)
            , Options.css "width" "100%"
            ]
    in
        case error of
            "" -> props
            _ -> Textfield.error (translate locale (Validation error)) :: props

smsProperties : Model -> List (Textfield.Property Msg)
smsProperties model =
    let
        error = model.auth.loginFormError
        locale = model.locale
        props =
            [ Textfield.label (translate model.locale SmsCode)
            , Textfield.value model.auth.loginCode
            , Textfield.floatingLabel
            , Textfield.onInput (AuthMsg << AuthMessages.ChangeLoginCode)
            , Options.css "width" "100%"
            ]
    in
        case error of
            "" -> props
            _ -> Textfield.error (translate locale (Validation error)) :: props

view : Model -> Html Msg
view model =
    div []
    [ Snackbar.view model.snackbar |> App.map Snackbar
    , grid
        []
        [ cell
            [ Elevation.e4
            , offset Desktop 4
            , offset Tablet 1
            , size Phone 12
            , size Tablet 6
            , size Desktop 4
            , Options.css "text-align" "center"
            ]
            [ img [ src "/images/logo.png", alt "logo" ] []
            , loginForm model
            ]
        ]
    ]
