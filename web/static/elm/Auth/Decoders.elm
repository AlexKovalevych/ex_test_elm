module Auth.Decoders exposing (..)

import Json.Decode exposing (Decoder, string, bool, (:=), object3)
import Auth.Models exposing (CurrentUser)

userDecoder : Decoder CurrentUser
userDecoder =
    object3 CurrentUser
        ("id" := string)
        ("email" := string)
        ("is_admin" := bool)
