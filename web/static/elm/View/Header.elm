module View.Header exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (..)
import Auth.Models exposing (CurrentUser)
import Auth.Messages as AuthMessages
import Material.Layout as Layout
import Material.Icon as Icon
import Material.Menu as Menu
import Html.Attributes exposing (src, width, style)
import Translation exposing (Language(English, Russian), TranslationId(..), translate)
import Routing exposing (getMenuRoutings, Route)

header : CurrentUser -> Model -> List (Html Msg)
header user model =
    [ Layout.row
        []
        [ Layout.title [] [ currentLocale model, text "Page title here" ]
        , Layout.spacer
        , Layout.navigation []
            [ Menu.render Mdl [0] model.mdl
                [ Menu.icon "language" ]
                [ Menu.item
                    [ Menu.onSelect <| SetLocale Russian ]
                    [ text <| translate model.locale RU ]
                , Menu.item
                    [ Menu.onSelect <| SetLocale English ]
                    [ text <| translate model.locale EN ]
                ]
            , Layout.link
                []
                [ text user.email ]
            , Layout.link
                [ Layout.onClick <| AuthMsg (AuthMessages.LogoutRequest)
                ]
                [ Icon.i "exit_to_app" ]
            ]
        ]
    ]

tabs : CurrentUser -> Model -> List (Html Msg)
tabs user model =
    case model.menu of
        Nothing -> []
        Just menu -> List.map (renderTab model.locale) (getMenuRoutings menu)

renderTab : Language -> Route -> Html Msg
renderTab locale route =
    text <| translate locale (Menu <| toString route)

currentLocale : Model -> Html Msg
currentLocale model =
    let
        props url = [ src url, width 25, style [ ( "margin-right", "1rem" ) ] ]
    in
        case model.locale of
            Russian -> img (props "/images/flags/ru_2.png") []
            English -> img (props "/images/flags/en_2.png") []
