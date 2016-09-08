module Socket.Update exposing (update)

import Debug
import Socket.Models exposing (Model, initialModel)
import Socket.Messages exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Native.Location
import Dict
import String
import List

initPhxSocket : String -> Phoenix.Socket.Socket Msg
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

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        InitSocket token ->
            let
                location = Native.Location.getLocation ()
                socket = initPhxSocket ("ws://" ++ location.host ++ "/socket/websocket?token=" ++ token)
            in
                ( { model | phxSocket = socket }
                , Cmd.none
                )

        JoinChannel name ->
            let
                channel = Phoenix.Channel.init name
                (phxSocket, phxCmd) = Phoenix.Socket.join channel model.phxSocket
                _ = Debug.log "joined channel: " phxCmd
                newChannels = Dict.insert (getChannelShortName name) name model.channels
            in
                ({ model | phxSocket = phxSocket, channels = newChannels }
                , Cmd.map PhoenixMsg phxCmd
                )

        RemoveSocket ->
            ( initialModel, Cmd.none )
