module Auth.Models exposing (..)

import User.Models exposing (..)

type alias CurrentUser =
    { id : String
    , email : String
    , is_admin : Bool
    , authenticationType : String
    , securePhoneNumber : String
    , locale : String
    , permissions : Permissions
    }

type User = Guest | LoggedUser CurrentUser

type alias Model =
    { user : User
    , token : String
    , loginFormEmail : String
    , loginFormPassword : String
    , loginFormError : String
    , loginCode : String
    , qrcodeUrl : Maybe String
    , serverTime: Maybe Int
    , currentServerTime : Int
    }

initialModel : Model
initialModel =
    { user = Guest
    , token = ""
    , loginFormEmail = ""
    , loginFormPassword = ""
    , loginFormError = ""
    , loginCode = ""
    , qrcodeUrl = Nothing
    , serverTime = Nothing
    , currentServerTime = 0
    }
