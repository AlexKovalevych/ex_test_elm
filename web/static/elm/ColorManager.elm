module ColorManager exposing (..)

import Models.Metrics exposing (Metrics(..))

paymentsAmountColor : (Int, Int, Int, Float)
paymentsAmountColor = (84, 169, 244, 1.0)

depositsAmountColor : (Int, Int, Int, Float)
depositsAmountColor = (128, 202, 75, 1.0)

cashoutsAmountColor : (Int, Int, Int, Float)
cashoutsAmountColor = (233, 88, 27, 1.0)

netgamingAmountColor : (Int, Int, Int, Float)
netgamingAmountColor = (246, 54, 115, 1.0)

betsAmountColor : (Int, Int, Int, Float)
betsAmountColor = (50, 170, 158, 1.0)

winsAmountColor : (Int, Int, Int, Float)
winsAmountColor = (248, 147, 27, 1.0)

rakeAmountColor : (Int, Int, Int, Float)
rakeAmountColor = (131, 74, 169, 1.0)

dashboardMetricsColor : Metrics -> (Int, Int, Int, Float)
dashboardMetricsColor metrics =
    case metrics of
        PaymentsAmount -> paymentsAmountColor
        DepositsAmount -> depositsAmountColor
        CashoutsAmount -> cashoutsAmountColor
        NetgamingAmount -> netgamingAmountColor
        BetsAmount -> betsAmountColor
        WinsAmount -> winsAmountColor
        RakeAmount -> rakeAmountColor
        _ -> (0, 0, 0, 1.0)

rgbaToString : (Int, Int, Int, Float) -> String
rgbaToString (r, g, b, a) =
    "rgba(" ++ (toString r) ++ "," ++ (toString g) ++ "," ++ (toString b) ++ "," ++ (toString a) ++ ")"
