module Auth.Update exposing (update)

import Auth.Models exposing (Model, User(Guest, LoggedUser))
import Auth.Messages exposing (..)

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadCurrentUser user ->
            ( { model | user = LoggedUser user }
            , Cmd.none
            )

        Logout ->
            ( { model | user = Guest }
            , Cmd.none
            )

        SetToken token ->
            ( { model | token = token }
            , Cmd.none
            )
