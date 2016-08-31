module Auth.Messages exposing (..)

import Auth.Models exposing (CurrentUser)

type Msg
    = LoadCurrentUser CurrentUser
