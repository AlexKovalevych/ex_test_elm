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
import Material.Grid exposing (Cell, grid, cell, size, offset, Device(..))
import Html.Attributes exposing (style, src, alt, href, target, width, height)
import Messages exposing (..)
import Material.Snackbar as Snackbar

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

storeLinks : List ((String, String))
storeLinks =
    [ ("https://itunes.apple.com/ua/app/google-authenticator/id388497605?mt=8", "/images/button_app_store.png")
    , ("http://apps.microsoft.com/windows/en-us/app/google-authenticator/7ea6de74-dddb-47df-92cb-40afac4d38bb", "/images/button_windows_store.png")
    , ("https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2", "/images/button_play_store.png")
    ]

renderStoreLink : (String, String) -> Cell Msg
renderStoreLink (linkUrl, imgUrl) =
    cell [size All 12]
    [ a
        [ href linkUrl
        , target "_blank"
        ]
        [ img [ src imgUrl, width 150, height 44 ] []
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
                    [ Textfield.label (translate model.locale <| Login "password")
                    , Textfield.password
                    , Textfield.value model.auth.loginFormPassword
                    , Textfield.floatingLabel
                    , Textfield.onInput (AuthMsg << AuthMessages.ChangeLoginPassword)
                    , Options.css "width" "100%"
                    ]
                , submitButton model 2 <| Login "submit"
                ]
        LoggedUser user ->
            case user.authenticationType of
                "sms" ->
                    form
                        [ onSubmit (AuthMsg AuthMessages.TwoFactor)
                        ]
                        [ div [ style [ ( "padding", "1rem" ) ] ]
                            [ text <| translate model.locale (SmsSent user.securePhoneNumber)
                            , twoFactorInput model <| Login "sms_code"
                            , submitButton model 1 <| Login "submit"
                            , Button.render Mdl [2] model.mdl
                                [ Button.raised
                                , Button.ripple
                                , Button.onClick (AuthMsg AuthMessages.SendSms)
                                , Button.type' "button"
                                , Options.css "margin-left" "1rem"
                                ]
                                [ text <| translate model.locale <| Login "resend_sms" ]
                            ]
                        ]
                _ ->
                    form
                        [ onSubmit (AuthMsg AuthMessages.TwoFactor)
                        ]
                        [ div []
                            [ img [ src <| qrCodeUrl model ] []
                            ]
                        , div [ style [ ( "padding", "1rem" ) ] ]
                            [ text <| translate model.locale (ServerTime <| serverTime model)
                            , twoFactorInput model <| Login "google_code"
                            , submitButton model 1 <| Login "submit"
                            ]
                        , div []
                            [ grid [] (List.map renderStoreLink storeLinks)
                            ]
                        ]

submitButton : Model -> Int -> TranslationId -> Html Msg
submitButton model key translationId =
    Button.render Mdl [key] model.mdl
        [ Button.raised
        , Button.ripple
        , Button.primary
        , Button.type' "submit"
        ]
        [ text <| translate model.locale translationId ]

emailProperties : Model -> List (Textfield.Property Msg)
emailProperties model =
    let
        error = model.auth.loginFormError
        locale = model.locale
        props =
            [ Textfield.label (translate locale <| Login "email")
            , Textfield.autofocus
            , Textfield.floatingLabel
            , Textfield.value model.auth.loginFormEmail
            , Textfield.onInput (AuthMsg << AuthMessages.ChangeLoginEmail)
            , Options.css "width" "100%"
            ]
    in
        case error of
            "" -> props
            _ -> Textfield.error (translate locale <| Login error) :: props

twoFactorInput : Model -> TranslationId -> Html Msg
twoFactorInput model translationId =
    let
        error = model.auth.loginFormError
        locale = model.locale
        props =
            [ Textfield.label (translate model.locale translationId)
            , Textfield.value model.auth.loginCode
            , Textfield.floatingLabel
            , Textfield.onInput (AuthMsg << AuthMessages.ChangeLoginCode)
            , Options.css "width" "100%"
            ]
        propsWithError = case error of
            "" -> props
            _ -> Textfield.error (translate locale <| Login error) :: props
    in
        Textfield.render Mdl [0] model.mdl propsWithError

