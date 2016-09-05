module Auth.View exposing (..)

import Html exposing (..)
import Material.Elevation as Elevation
import Material.Options as Options
import Auth.Messages as AuthMessages
import Material.Textfield as Textfield
import Material.Button as Button
import Models exposing (..)
import Html.Events exposing (onSubmit)
import Translation exposing (..)
import Material.Grid exposing (grid, cell, size, offset, Device(..))
import Html.Attributes exposing (style, src, alt)
import Messages exposing (..)

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

view : Model -> Html Msg
view model =
    grid
        []
        [ cell
            [ Elevation.e2
            , offset All 4
            , size All 4
            , Options.css "text-align" "center"
            ]
            [ img [ src "/images/logo.png", alt "logo" ] []
            , form
                [ style [ ("padding", "20px") ]
                , onSubmit <| AuthMsg AuthMessages.LoginRequest
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
            ]
        ]
