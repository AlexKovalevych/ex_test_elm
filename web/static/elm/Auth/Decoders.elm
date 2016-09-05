module Auth.Decoders exposing (..)

import Json.Decode exposing (..)
import Auth.Models exposing (CurrentUser)

userDecoder : Decoder CurrentUser
userDecoder =
    object3 CurrentUser
        ("id" := string)
        ("email" := string)
        ("is_admin" := bool)

userErrorDecoder : Decoder String
userErrorDecoder =
    at ["error"] string
