module Auth.Api exposing (..)

import Auth.Encoders exposing (encodeLogin, encodeTwoFactor)
import Auth.Decoders exposing (logoutDecoder, userSuccessDecoder, userErrorDecoder)
import Auth.Messages exposing (..)
import Auth.Models exposing (Model)
import Json.Encode as JE
import Json.Decode as JD
import Http exposing (fromJson, send, defaultSettings, empty)
import Task
import Xhr exposing (post)
import Translation exposing (..)

login : Model -> Cmd Msg
login model =
    let
        task = fromJson userSuccessDecoder (post "/api/v1/auth" <| encodeLogin model)
    in
        Cmd.map ForSelf <| Task.perform (userErrorDecoder >> LoginFailed) LoginUser task

logout : Cmd Msg
logout =
    let request =
        { verb = "DELETE"
        , headers = [
            ("Accept", "application/json"),
            ("Content-Type", "application/json")
        ]
        , url = "/api/v1/auth"
        , body = empty
        }
        task = fromJson logoutDecoder (send defaultSettings request)
    in
        Cmd.map ForSelf <| Task.perform (\_ -> NoOp) (\_ -> RemoveToken) task

twoFactor : Model -> Cmd Msg
twoFactor model =
    let
        task = fromJson userSuccessDecoder (post "/api/v1/two_factor" <| encodeTwoFactor model)
    in
        Cmd.map ForSelf <| Task.perform (userErrorDecoder >> LoginFailed) LoginUser task

sendSms : Cmd Msg
sendSms =
    let
        task = fromJson JD.string (post "/api/v1/send_sms" JE.null)
        addToast msg = (\_ -> AddToast <| Login msg)
    in
        Cmd.map ForParent <| Task.perform (addToast "sms_was_not_sent") (addToast "sms_was_sent") task
