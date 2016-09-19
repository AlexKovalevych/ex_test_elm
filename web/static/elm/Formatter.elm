module Formatter exposing (..)

import List
import Models.Metrics exposing (Metrics(..))
import Numeral exposing (format)
import Translation exposing (getDateConfig)

dayFormat : String
dayFormat = "%b %e, %Y"

monthFormat : String
monthFormat = "%b %Y"

yearFormat : String
yearFormat = "%Y"

formatMetricsValue : Metrics -> Float -> String
formatMetricsValue metrics value =
    case metrics of
        AverageArpu -> formatCashValue value
        AverageDeposit -> formatCashValue value
        AverageFirstDeposit -> formatCashValue value
        BetsAmount -> formatCashValue value
        CashoutsAmount -> formatCashValue <| abs value
        DepositsAmount -> formatCashValue value
        FirstDepositsAmount -> formatCashValue value
        NetgamingAmount -> formatCashValue value
        PaymentsAmount -> formatCashValue value
        RakeAmount -> formatCashValue value
        WinsAmount -> formatCashValue value
        _ -> formatNumberValue value

formatCashValue : Float -> String
formatCashValue value =
    format "$0,0" <| value / 100

formatNumberValue value =
    format "0,0" <| value
