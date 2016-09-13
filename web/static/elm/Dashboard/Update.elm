module Dashboard.Update exposing (..)

import Dashboard.Messages exposing (..)
import Dashboard.Models exposing (..)
import Json.Encode as JE
import Socket.Messages as SocketMessages exposing (InternalMsg(DecodeCurrentUser), PushModel)
import Update.Never exposing (never)
import Task

update : Dashboard.Messages.InternalMsg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadDashboardData dashboard ->
            dashboard ! []

        SetDashboardProjectsType msg ->
            model !
                [ Task.perform never ForParent (Task.succeed <| UpdateDashboardProjectsType msg ) ]

        SetDashboardSort msg ->
            model !
                [ Task.perform never ForParent (Task.succeed <| UpdateDashboardSort msg ) ]

        SetDashboardCurrentPeriod msg ->
            model !
                [ Task.perform never ForParent (Task.succeed <| UpdateDashboardCurrentPeriod msg ) ]

        SetDashboardComparisonPeriod msg ->
            model !
                [ Task.perform never ForParent (Task.succeed <| UpdateDashboardComparisonPeriod msg ) ]

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

        ForParent (UpdateDashboardSort value) ->
            let
                payload = JE.string <| value
                _ = Debug.log "here: " payload
                success = DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_sort" "users" payload success error
            in
                onSetDashboardSort pushModel

        ForParent (UpdateDashboardCurrentPeriod value) ->
           let
                payload = JE.string <| value
                success = DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_period" "users" payload success error
            in
                onSetDashboardCurrentPeriod pushModel

        ForParent (UpdateDashboardComparisonPeriod value) ->
           let
                payload = JE.string <| toString <| value
                success = DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_comparison_period" "users" payload success error
            in
                onSetDashboardComparisongPeriod pushModel

        ForParent (UpdateDashboardProjectsType value) ->
           let
                payload = JE.string <| value
                success = DecodeCurrentUser
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_projects_type" "users" payload success error
            in
                onSetDashboardProjectsType pushModel
