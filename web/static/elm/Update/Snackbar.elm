module Update.Snackbar exposing (..)

import Models exposing (..)
import Messages exposing (..)
import Material.Snackbar as Snackbar

addToast : String -> Model -> (Model, Cmd Msg)
addToast msg model =
    let
        (snackbar, effect) =
            Snackbar.add (Snackbar.toast NoOp msg) model.snackbar
    in
        { model | snackbar = snackbar } ! [ Cmd.map Snackbar effect ]
