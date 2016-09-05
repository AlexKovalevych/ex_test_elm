module Auth.Models exposing (..)

type alias CurrentUser =
    { id : String
    , email : String
    , is_admin : Bool
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
--    , qrcodeUrl : Maybe String
--    , error : Maybe String
--    , smsSent : Maybe Bool
--    , serverTime: Maybe Int
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
    }

isLogged : User -> Bool
isLogged user =
    case user of
        Guest -> False
        LoggedUser _ -> True

--userInitialModel : User
--userInitialModel =
--    { email = ""
--    , is_admin = False
--    }
