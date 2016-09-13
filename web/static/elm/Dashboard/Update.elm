module Dashboard.Update exposing (..)

import Dashboard.Messages exposing (..)
import Dashboard.Models exposing (..)
import Json.Encode as JE
import Socket.Messages as SocketMessages exposing (InternalMsg(DecodeCurrentUser), PushModel)

update : Dashboard.Messages.InternalMsg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadDashboardData dashboard
            ->
                let
                    _ = Debug.log "here: " dashboard
                in
                    dashboard ! []
        _ ->
            model ! []

type alias TranslationDictionary msg =
    { onInternalMessage : Dashboard.Messages.InternalMsg -> msg
    , onSetDashboardSort : PushModel -> msg
    , onSetDashboardCurrentPeriod : PushModel -> msg
    , onSetDashboardComparisongPeriod : PushModel -> msg
    , onSetDashboardProjectsType : PushModel -> msg
    }

type alias Translator msg =
    Msg -> msg

translator : TranslationDictionary msg -> Translator msg
translator
    { onInternalMessage
    , onSetDashboardSort
    , onSetDashboardCurrentPeriod
    , onSetDashboardComparisongPeriod
    , onSetDashboardProjectsType
    } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (SetDashboardSort value) ->
            let
                payload = JE.string <| toString <| value
                success = DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_sort" "users" payload success error
            in
                onSetDashboardSort pushModel

        ForParent (SetDashboardCurrentPeriod value) ->
           let
                payload = JE.string <| toString <| value
                success = DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_period" "users" payload success error
            in
                onSetDashboardCurrentPeriod pushModel

        ForParent (SetDashboardComparisonPeriod value) ->
           let
                payload = JE.string <| toString <| value
                success = DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_comparison_period" "users" payload success error
            in
                onSetDashboardComparisongPeriod pushModel

        ForParent (SetDashboardProjectsType value) ->
           let
                payload = JE.string <| toString <| value
                success = DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_projects_type" "users" payload success error
            in
                onSetDashboardProjectsType pushModel
