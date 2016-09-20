module ColorManager exposing (..)

import Models.Metrics exposing (Metrics(..))

paymentsAmountColor : (Int, Int, Int, Int)
paymentsAmountColor = (84, 169, 244, 1)

depositsAmountColor : (Int, Int, Int, Int)
depositsAmountColor = (128, 202, 75, 1)

cashoutsAmountColor : (Int, Int, Int, Int)
cashoutsAmountColor = (233, 88, 27, 1)

dashboardMetricsColor : Metrics -> (Int, Int, Int, Int)
dashboardMetricsColor metrics =
    case metrics of
        PaymentsAmount -> paymentsAmountColor
        DepositsAmount -> depositsAmountColor
        CashoutsAmount -> cashoutsAmountColor
        _ -> (0, 0, 0, 1)
