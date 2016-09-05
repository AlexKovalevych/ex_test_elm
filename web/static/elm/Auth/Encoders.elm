module Auth.Encoders exposing (..)

import Auth.Models exposing (..)
import Json.Encode exposing (..)

encodeLogin : Model -> Value
encodeLogin model =
    object
        [ ( "email", string model.loginFormEmail )
        , ( "password", string model.loginFormPassword )
        ]
