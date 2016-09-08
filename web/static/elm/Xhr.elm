module Xhr exposing (..)

import Task exposing (Task)
import Json.Encode as JE
import Http exposing (send, defaultSettings, string, RawError, Response, Error)

post : String -> JE.Value -> Task RawError Response
post path encoded =
    send defaultSettings
        { verb = "POST"
        , url = path
        , body = string (encoded |> JE.encode 0)
        , headers = [ ( "Content-Type", "application/json" ) ]
        }

stringFromHttpError : Error -> String
stringFromHttpError e =
    case e of
        Http.Timeout -> "Timeout"
        Http.NetworkError -> "Network Error"
        Http.UnexpectedPayload msg -> msg
        Http.BadResponse _ msg -> msg
