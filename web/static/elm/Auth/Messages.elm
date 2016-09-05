module Auth.Messages exposing (..)

import Auth.Models exposing (CurrentUser)
import Auth.Decoders exposing (LoginResponse)

type Msg
    = LoadCurrentUser CurrentUser
    | LoginFailed String
    | LoginRequest
    | ChangeLoginEmail String
    | ChangeLoginPassword String
    | SetToken String
    | LoginUser LoginResponse
    | RemoveToken
    | Logout
    | NoOp
