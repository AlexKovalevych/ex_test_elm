module Auth.Models exposing (..)

type alias User =
    { email : String
    }

type alias Model =
    { user : User
    , status : Status
    , token : String
--    , qrcodeUrl : Maybe String
--    , error : Maybe String
--    , smsSent : Maybe Bool
--    , serverTime: Maybe Int
    }

--type AuthModel = EmptyAuth | Logged Auth

--initAuth : AuthModel
--initAuth = EmptyAuth

type Status
    = LoggedIn
    | Anonymous

initialModel : Model
initialModel =
    { user = userInitialModel
    , status = Anonymous
    , token = ""
    }

userInitialModel : User
userInitialModel =
    { email = ""
    }
