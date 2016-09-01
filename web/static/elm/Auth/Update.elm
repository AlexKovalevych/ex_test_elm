module Auth.Update exposing (update)

import Debug
import Auth.Models exposing (Model)
import Auth.Messages exposing (..)

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadCurrentUser user ->
            ( { model | user = user }
            , Cmd.none
            )
