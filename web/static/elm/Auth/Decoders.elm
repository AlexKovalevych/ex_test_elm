module Auth.Decoders exposing (..)

import Auth.Models exposing (CurrentUser, UserSettings)
import Json.Decode exposing (..)
import Http
import User.Decoders exposing (permissionsDecoder)
import Xhr exposing (stringFromHttpError)

type alias LoginResponse =
    { user : CurrentUser
    , jwt : Maybe String
    , url : Maybe String
    , serverTime : Maybe Int
    }

userSuccessDecoder : Decoder LoginResponse
userSuccessDecoder =
    object4 LoginResponse
        ("user" := userDecoder)
        (maybe ("jwt" := string))
        (maybe ("url" := string))
        (maybe ("serverTime" := int))

userDecoder : Decoder CurrentUser
userDecoder =
    object8 CurrentUser
        ("id" := string)
        ("email" := string)
        ("is_admin" := bool)
        ("authenticationType" := string)
        ("securePhoneNumber" := string)
        ("locale" := string)
        ("permissions" := permissionsDecoder)
        ("settings" := settingsDecoder)

type alias LogoutResponse =
    { ok : Bool
    }

logoutDecoder : Decoder LogoutResponse
logoutDecoder =
    object1 LogoutResponse
        ("ok" := bool)

userErrorDecoder : Http.Error -> String
userErrorDecoder msg =
    let
        stringMsg = stringFromHttpError msg
    in
        case decodeString (at ["error"] string) stringMsg of
            Ok error -> error
            Err _ -> ""

settingsDecoder : Decoder UserSettings
settingsDecoder =
    object5 UserSettings
        ("dashboardChartType" := string)
        ("dashboardComparePeriod" := int)
        ("dashboardPeriod" := string)
        ("dashboardProjectsType" := string)
        ("dashboardSort" := string)
