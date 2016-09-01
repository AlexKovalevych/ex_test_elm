module Auth.Messages exposing (..)

import Auth.Models exposing (User)

type Msg
    = LoadCurrentUser User
    | SetToken String
