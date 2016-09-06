module Auth.Models exposing (..)

type alias CurrentUser =
    { id : String
    , email : String
    , is_admin : Bool
    , authenticationType : String
    , securePhoneNumber : String
    }

type User = Guest | LoggedUser CurrentUser

type alias LoginForm =
    { email : String
    , password : String
    --, error : Maybe String
    }

type alias Model =
    { user : User
    , token : String
    , loginFormEmail : String
    , loginFormPassword : String
    , loginFormError : String
    , qrcodeUrl : Maybe String
    , serverTime: Maybe Int
--    , error : Maybe String
--    , smsSent : Maybe Bool
    }

type Status
    = LoggedIn
    | Anonymous

initialModel : Model
initialModel =
    { user = Guest
    , token = ""
    , loginFormEmail = ""
    , loginFormPassword = ""
    , loginFormError = ""
    , qrcodeUrl = Nothing
    , serverTime = Nothing
    }

isLogged : User -> Bool
isLogged user =
    case user of
        Guest -> False
        LoggedUser _ -> True
