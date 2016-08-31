module Auth.Models exposing (..)

type alias CurrentUser =
    { email : String
    }

type alias Auth =
    { user : CurrentUser
    , qrcodeUrl : Maybe String
    , error : Maybe String
    , smsSent : Maybe Bool
    , serverTime: Maybe Int
    }

type AuthModel = EmptyAuth | Logged Auth

initAuth : AuthModel
initAuth = EmptyAuth
