module Dashboard.Update exposing (..)

import Char
import Dashboard.Messages exposing (..)
import Dashboard.Models exposing (..)
import Json.Encode as JE
import Models.Metrics exposing (typeToString)
import Socket.Messages as SocketMessages exposing
    (InternalMsg(DecodeCurrentUser, DecodeDashboardData)
    , PushModel
    )
import String
import Task
import Update.Never exposing (never)

update : Dashboard.Messages.InternalMsg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadDashboardData dashboard ->
            dashboard ! []

        SetDashboardProjectsType msg ->
            model !
                [ Task.perform never ForParent (Task.succeed <| UpdateDashboardProjectsType msg ) ]

        SetDashboardSort msg ->
            let
                metrics = case String.uncons <| typeToString msg of
                    Nothing -> ""
                    Just value -> String.cons (Char.toLower <| fst value) (snd value)
            in
                model !
                    [ Task.perform never ForParent (Task.succeed <| UpdateDashboardSort metrics) ]

        SetDashboardCurrentPeriod msg ->
            model !
                [ Task.perform never ForParent (Task.succeed <| UpdateDashboardData <| Just msg )
                , Task.perform never ForParent (Task.succeed <| UpdateDashboardCurrentPeriod msg ) ]

        SetDashboardComparisonPeriod msg ->
            model !
                [ Task.perform never ForParent (Task.succeed <| UpdateDashboardData Nothing )
                , Task.perform never ForParent (Task.succeed <| UpdateDashboardComparisonPeriod msg ) ]

        SetSplineTooltip splineTooltip ->
            { model | splineTooltip = splineTooltip } ! []

        _ ->
            model ! []

type alias TranslationDictionary msg =
    { onInternalMessage : Dashboard.Messages.InternalMsg -> msg
    , onUpdateDashboardData : PushModel -> msg
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
    , onUpdateDashboardData
    , onSetDashboardSort
    , onSetDashboardCurrentPeriod
    , onSetDashboardComparisongPeriod
    , onSetDashboardProjectsType
    } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (UpdateDashboardData maybePeriod) ->
            let
                payload = case maybePeriod of
                    Nothing -> JE.null
                    Just period -> JE.string period
                success = DecodeDashboardData
                error = (\e -> SocketMessages.NoOp)
                pushModel = PushModel "dashboard_stats" "users" payload success error
            in
                onUpdateDashboardData pushModel

        ForParent (UpdateDashboardSort value) ->
            let
                payload = JE.string <| value
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
