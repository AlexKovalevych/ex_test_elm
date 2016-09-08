module Socket.Update exposing (..)

import Debug
import Dict
import List
import Native.Location
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Socket.Models exposing (Model, initialModel)
import Socket.Messages exposing (..)
import String
import Translation exposing (Language)

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

        PushMessage msg channel payload ->
            let
                push = Phoenix.Push.init msg (getFullChannelName channel model)
                    |> Phoenix.Push.withPayload payload
                ( phxSocket, phxCmd ) = Phoenix.Socket.push push model.phxSocket
            in
                { model | phxSocket = phxSocket } ! [ Cmd.map (ForSelf << PhoenixMsg) phxCmd ]

        RemoveSocket ->
            initialModel ! []

type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onSetLocale : Language -> msg
    }

type alias Translator msg =
    Msg -> msg

translator : TranslationDictionary msg -> Translator msg
translator { onInternalMessage, onSetLocale } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

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
