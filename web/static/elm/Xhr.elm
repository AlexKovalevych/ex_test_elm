module Xhr exposing (..)

import Task exposing (Task)
import Models exposing (..)
import Json.Encode as JE
--import Json.Decode as JD
--import Http exposing (send, defaultSettings, string, RawError, Response, Error)
import Translation exposing (..)
import HttpBuilder exposing (..)


post : String -> JE.Value -> RequestBuilder
post path body reader =
  HttpBuilder.post path
    |> withJsonBody body
    |> withHeader "Content-Type" "application/json"
    --|> withTimeout (10 * Time.second)
    |> withCredentials
    --|> send reader stringReader

--post : String -> JE.Value -> Task RawError Response
--post path encoded =
--    send defaultSettings
--        { verb = "POST"
--        , url = path
--        , body = string (encoded |> JE.encode 0)
--        , headers = [ ( "Content-Type", "application/json" ) ]
--        }

--stringFromHttpError : Error -> String
--stringFromHttpError e =
--    case e of
--        Http.Timeout -> "Timeout"
--        Http.NetworkError -> "Network Error"
--        Http.UnexpectedPayload msg -> msg
--        Http.BadResponse _ msg -> msg
