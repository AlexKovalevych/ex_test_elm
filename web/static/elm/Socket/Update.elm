module Socket.Update exposing (..)

import Auth.Decoders exposing (userDecoder)
import Auth.Models exposing (CurrentUser)
import Debug
import Dict
import Json.Encode as JE
import Json.Decode as JD
import List
import Native.Location
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Socket.Models exposing (Model, initialModel)
import Socket.Messages exposing (..)
import String
import Task
import Translation exposing (Language)
import Update.Never exposing (never)

update : InternalMsg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
            in
                { model | phxSocket = phxSocket } ! [ Cmd.map (ForSelf << PhoenixMsg) phxCmd ]

        InitSocket token ->
            let
                location = Native.Location.getLocation ()
                socket = initPhxSocket ("ws://" ++ location.host ++ "/socket/websocket?token=" ++ token)
            in
                { model | phxSocket = socket } ! []

        JoinChannel name ->
            let
                channel = Phoenix.Channel.init name
                ( phxSocket, phxCmd ) = Phoenix.Socket.join channel model.phxSocket
                _ = Debug.log "joined channel: " phxCmd
                newChannels = Dict.insert (getChannelShortName name) name model.channels
            in
                { model | channels = newChannels, phxSocket = phxSocket } ! [ Cmd.map (ForSelf << PhoenixMsg) phxCmd ]

        PushMessage pushModel ->
            let
                push = Phoenix.Push.init pushModel.msg (getFullChannelName pushModel.channel model)
                    |> Phoenix.Push.withPayload pushModel.payload
                    |> Phoenix.Push.onOk pushModel.successDecoder
                    |> Phoenix.Push.onError pushModel.errorDecoder
                ( phxSocket, phxCmd ) = Phoenix.Socket.push push model.phxSocket
            in
                { model | phxSocket = phxSocket } ! [ Cmd.map (ForSelf << PhoenixMsg) phxCmd ]

        --For server broadcasted messages
        SubscribeToUsersChannel channel ->
            model ! []

        --For server broadcasted messages
        SubscribeToAdminsChannel channel ->
            model ! []

        DecodeCurrentUser raw ->
            case JD.decodeValue userDecoder raw of
                Ok currentUser ->
                    model ! [ Task.perform never ForParent (Task.succeed <| UpdateCurrentUser currentUser) ]
                Err error ->
                    let _ = Debug.log "NOW WORKING??" error
                    in
                    ( model, Cmd.none )

        RemoveSocket ->
            initialModel ! []

        NoOp ->
            model ! []

type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onSetLocale : Language -> msg
    , onUpdateCurrentUser : CurrentUser -> msg
    }

type alias Translator msg =
    Msg -> msg

translator : TranslationDictionary msg -> Translator msg
translator { onInternalMessage, onSetLocale, onUpdateCurrentUser } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (UpdateCurrentUser value) ->
            onUpdateCurrentUser value

        ForParent (SetLocale locale) ->
            onSetLocale locale

initPhxSocket : String -> Phoenix.Socket.Socket InternalMsg
initPhxSocket server =
    Phoenix.Socket.init server
    |> Phoenix.Socket.withDebug

getChannelShortName : String -> String
getChannelShortName name =
    let
        parts = String.split ":" name |> List.head
    in
        case parts of
            Nothing -> name
            Just part -> part

getFullChannelName : String -> Model -> String
getFullChannelName name model =
    let channel =
        Dict.get name model.channels
    in
        case channel of
            Nothing -> ""
            Just fullName -> fullName
