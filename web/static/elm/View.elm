module View exposing (..)

import Html exposing (..)
import Html.App
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class, href, style)
import Models exposing (..)
import Messages exposing (..)
import Routing exposing (..)
--import Languages.View


view : Model -> Html Msg
view model =
    let
        _ = Debug.log "model: " model
    in
        div []
            [ menu model
            , pageView model
            ]


menu : Model -> Html Msg
menu model =
    case model.route of
        LoginRoute ->
            div [] []
        _ ->
            div [ class "p2 white bg-black" ]
                [ div []
                    [ menuLink ShowDashboard "btnHome" "Dashboard"
                    , text "|"
                    , menuLink ShowLogin "btnLogin" "Login"
                    ]
                ]


menuLink : Msg -> String -> String -> Html Msg
menuLink message viewId label =
    a
        [ id viewId
        , href "javascript://"
        , onClick message
        , class "white px2"
        ]
        [ text label ]


pageView : Model -> Html Msg
pageView model =
    case model.route of
        DashboardRoute ->
            div [ class "p2" ]
                [ h1 [ id "title", class "m0" ] [ text "Dashboard" ]
                , div [] [ text "Click on Languages to start routing" ]
                ]

        LoginRoute ->
            div [ class "row" ]
                [ div [ class "col-xs-offset-4 col-xs-4" ] []
                ]

        --LanguagesRoutes languagesRoute ->
        --    let
        --        viewModel =
        --            { languages = model.languages
        --            , route = languagesRoute
        --            , location = model.location
        --            }
        --    in
        --        div [ class "p2" ]
        --            [ h1 [ id "title", class "m0" ] [ text "Languages" ]
        --            , Html.App.map LanguagesMsg (Languages.View.view viewModel)
        --            ]

        NotFoundRoute ->
            notFoundView model


notFoundView : Model -> Html msg
notFoundView model =
    div []
        [ text "Not Found"
        ]
