module Formatter exposing (..)

import List
import Numeral exposing (format)

cashValues : List String
cashValues =
    [ "averageArpu"
    , "averageDeposit"
    , "averageFirstDeposit"
    , "betsAmount"
    , "cashoutsAmount"
    , "depositsAmount"
    , "firstDepositsAmount"
    , "netgamingAmount"
    , "paymentsAmount"
    , "rakeAmount"
    , "winsAmount"
    ]

formatMetricsValue : String -> Float -> String
formatMetricsValue metrics value =
    if List.member metrics cashValues then
        formatCashValue value
    else
        formatNumberValue value

formatCashValue : Float -> String
formatCashValue value =
    format "$0,0" <| value / 100

formatNumberValue value =
    format "0,0" <| value
