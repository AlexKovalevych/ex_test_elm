module Xhr exposing (..)

import Task exposing (Task)
import Models exposing (..)
import Json.Encode as JE
import Json.Decode as JD
import Http exposing (send, defaultSettings, string, RawError, Response)

post : String -> JE.Value -> JD.Decoder a -> Task RawError Response
post path encoded decoder =
    send defaultSettings
        { verb = "POST"
        , url = path
        , body = string (encoded |> JE.encode 0)
        , headers = [ ( "Content-Type", "application/json" ) ]
        }
