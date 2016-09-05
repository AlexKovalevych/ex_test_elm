module Auth.Messages exposing (..)

import Auth.Models exposing (CurrentUser)

type Msg
    = LoadCurrentUser CurrentUser
    | LoginRequest
    | ChangeLoginEmail String
    | ChangeLoginPassword String
    | SetToken String
    | RemoveToken
    | Logout
    | NoOp
