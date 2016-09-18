module Models.Metrics exposing (..)

type Metrics
    = AuthorizationsNumber
    | AverageArpu
    | AverageDeposit
    | AverageFirstDeposit
    | BetsAmount
    | CashoutsAmount
    | CashoutsNumber
    | DepositorsNumber
    | DepositsAmount
    | DepositsNumber
    | FirstDepositorsNumber
    | FirstDepositsAmount
    | NetgamingAmount
    | PaymentsAmount
    | PaymentsNumber
    | RakeAmount
    | SignupsNumber
    | WinsAmount
    | NoOp

stringToType : String -> Metrics
stringToType metrics =
    case metrics of
        "authorizationsNumber" -> AuthorizationsNumber
        "averageArpu" -> AverageArpu
        "averageDeposit" -> AverageDeposit
        "averageFirstDeposit" -> AverageFirstDeposit
        "betsAmount" -> BetsAmount
        "cashoutsAmount" -> CashoutsAmount
        "cashoutsNumber" -> CashoutsNumber
        "depositorsNumber" -> DepositorsNumber
        "depositsAmount" -> DepositsAmount
        "depositsNumber" -> DepositsNumber
        "firstDepositorsNumber" -> FirstDepositorsNumber
        "firstDepositsAmount" -> FirstDepositsAmount
        "netgamingAmount" -> NetgamingAmount
        "paymentsAmount" -> PaymentsAmount
        "paymentsNumber" -> PaymentsNumber
        "rakeAmount" -> RakeAmount
        "signupsNumber" -> SignupsNumber
        "winsAmount" -> WinsAmount
        _ -> NoOp

typeToString : Metrics -> String
typeToString = toString
