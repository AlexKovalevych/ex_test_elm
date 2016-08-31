module Socket.Update exposing (update)

import Debug
import Socket.Models exposing (..)
import Socket.Messages exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Native.Location

initPhxSocket : String -> Phoenix.Socket.Socket Msg
initPhxSocket server =
    Phoenix.Socket.init server
    |> Phoenix.Socket.withDebug

update : Msg -> Socket -> ( Socket, Cmd Msg )
update message model =
    case Debug.log "socket message" message of
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
            in
                ({ model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )