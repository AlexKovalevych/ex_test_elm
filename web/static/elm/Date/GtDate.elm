module Date.GtDate exposing (..)

import Array
import Date
import Date.Extra.Create exposing (dateFromFields)
import List
import Result
import String

dateFromMonthString : String -> Date.Date
dateFromMonthString dateString =
    let
        parts = String.split "-" dateString
        |> List.map ( String.toInt >> Result.withDefault 0 )
        |> Array.fromList
        year = getValueFromMaybe <| Array.get 0 parts
        month = getValueFromMaybe <| Array.get 1 parts
        day = getValueFromMaybe <| Array.get 2 parts
    in
        dateFromFields year (getMonth month) day 0 0 0 0

getMonth : Int -> Date.Month
getMonth month =
    case month of
        1 -> Date.Jan
        2 -> Date.Feb
        3 -> Date.Mar
        4 -> Date.Apr
        5 -> Date.May
        6 -> Date.Jun
        7 -> Date.Jul
        8 -> Date.Aug
        9 -> Date.Sep
        10 -> Date.Oct
        11 -> Date.Nov
        _ -> Date.Dec

getValueFromMaybe : Maybe Int -> Int
getValueFromMaybe maybeValue =
    case maybeValue of
        Nothing -> 0
        Just value -> value
