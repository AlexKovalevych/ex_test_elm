module Project.Decoders exposing (..)

import Json.Decode exposing (..)
import Project.Models exposing (Project)

projectDecoder : Decoder Project
projectDecoder =
    object8 Project
        ("enabled" := bool)
        ("id" := string)
        ("isPartner" := bool)
        ("isPoker" := bool)
        ("item_id" := string)
        ("prefix" := string)
        ("title" := string)
        ("url" := string)
