module Dashboard.Update exposing (..)

import Dashboard.Messages exposing (..)
import Dashboard.Models exposing (..)

update : InternalMsg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        _ -> model ! []
