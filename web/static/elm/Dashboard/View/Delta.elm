module Dashboard.View.Delta exposing (..)

import Formatter exposing (formatMetricsValue)
import Html exposing (..)
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Typography as Typography
import Material.Options as Options
import Material.Icon as Icon
import Messages exposing (..)

delta : Float -> Float -> String -> Html Messages.Msg
delta currentValue comparisonValue metrics =
    let
        current = abs(currentValue)
        comparison = abs(comparisonValue)
        diff = current - comparison
        percentDelta = toString <| if comparison == 0 then 0 else round(current / comparison * 100)
    in
        if diff > 0 then
            div []
                [ Icon.view "trending_up" [Icon.size18]
                , text <| formatMetricsValue metrics diff ++ " | " ++ percentDelta ++ "%"
                ]
        else if diff < 0 then
            div []
                [ Icon.view "trending_down" [Icon.size18]
                , text <| formatMetricsValue metrics diff ++ " | " ++ percentDelta ++ "%"
                ]
        else
            div []
                [ Icon.view "trending_flat" [Icon.size18]
                , text <| formatMetricsValue metrics diff ++ " | " ++ percentDelta ++ "%"
                ]
