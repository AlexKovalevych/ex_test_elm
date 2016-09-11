module Routing exposing (..)

import Array
import List
import Hop exposing (..)
import Hop.Types exposing (Config)
import UrlParser exposing ((</>), oneOf, int, s, string)

config : Config
config =
    { basePath = "/"
    , hash = False
    }

routes : UrlParser.Parser (Route -> a) a
routes =
    oneOf matchers

type Route
    = DashboardRoute
    | FinanceRoutes FinanceRoute
    | StatisticRoutes StatisticRoute
    | CalendarRoutes CalendarRoute
    | PlayersRoutes PlayerRoute
    | SettingsRoutes SettingsRoute

    --Other routings
    | LoginRoute
    | NotFoundRoute

type FinanceRoute
    = PaymentCheckRoutes PaymentCheckRoute
    | PaymentSystemRoutes PaymentSystemRoute
    | InputReport
    | FundsFlow
    | MonthlyBalances

type PaymentCheckRoute
    = PaymentCheckList
    | PaymentCheckView String
    | PaymentCheckCreate

type PaymentSystemRoute
    = PaymentSystemList
    | PaymentSystemView String
    | PaymentSystemCreate

type StatisticRoute
    = ConsolidatedReport
    | LtvReport
    | SegmentsReport
    | RetentionsReport
    | ActivityWaves
    | TimelineReport
    | CohortsReport

type CalendarRoute
    = EventsRoutes EventsRoute
    | EventsTypesRoutes EventsTypesRoute
    | EventsGroupsRoutes EventsGroupsRoute

type EventsRoute
    = EventsList
    | EventsEdit String
    | EventsCreate

type EventsTypesRoute
    = EventsTypesList
    | EventsTypesEdit String
    | EventsTypesCreate

type EventsGroupsRoute
    = EventsGroupsList
    | EventsGroupsEdit String
    | EventsGroupsCreate

type PlayerRoute
    = Multiaccounts
    | SignupChannelsRoutes SignupChannelsRoute

type SignupChannelsRoute
    = SignupChannelList
    | SignupChannelEdit String
    | SignupChannelCreate

type SettingsRoute
    = UserRoutes UserRoute
    | ProjectRoutes ProjectRoute
    | NotificationRoutes NotificationRoute
    | Permissions
    | DataSourceRoutes DataSourceRoute
    | SmtpServerRoutes SmtpServerRoute

type UserRoute
    = UserList
    | UserEdit String
    | UserCreate

type ProjectRoute
    = ProjectList
    | ProjectEdit String
    | ProjectCreate

type NotificationRoute
    = NotificationList
    | NotificationEdit String
    | NotificationCreate

type DataSourceRoute
    = DataSourceList
    | DataSourceEdit String
    | DataSourceCreate

type SmtpServerRoute
    = SmtpServerList
    | SmtpServerEdit String
    | SmtpServerCreate

type Menu
    --= Dashboard
    = Finance
    | Statistics
    | Calendar
    | Players
    | Settings

financeRoutes : List FinanceRoute
financeRoutes =
    [ PaymentCheckRoutes PaymentCheckList
    , PaymentSystemRoutes PaymentSystemList
    , InputReport
    , FundsFlow
    , MonthlyBalances
    ]

statisticRoutes : List StatisticRoute
statisticRoutes =
    [ ConsolidatedReport
    , LtvReport
    , SegmentsReport
    , RetentionsReport
    , ActivityWaves
    , TimelineReport
    , CohortsReport
    ]

calendarRoutes : List CalendarRoute
calendarRoutes =
    [ EventsRoutes EventsList
    , EventsTypesRoutes EventsTypesList
    , EventsGroupsRoutes EventsGroupsList
    ]

playersRoutes : List PlayerRoute
playersRoutes =
    [ Multiaccounts
    , SignupChannelsRoutes SignupChannelList
    ]

settingsRoutes : List SettingsRoute
settingsRoutes =
    [ UserRoutes UserList
    , ProjectRoutes ProjectList
    , NotificationRoutes NotificationList
    , Permissions
    , DataSourceRoutes DataSourceList
    , SmtpServerRoutes SmtpServerList
    ]

matchers : List (UrlParser.Parser (Route -> a) a)
matchers =
    [ UrlParser.format DashboardRoute (s "")
    , UrlParser.format LoginRoute (s "login")
    , UrlParser.format FinanceRoutes (s "finance" </> (oneOf financeMatchers))
    , UrlParser.format StatisticRoutes (s "statistics" </> (oneOf statisticMatchers))
    , UrlParser.format CalendarRoutes (s "event_calendar" </> (oneOf calendarMatchers))
    , UrlParser.format PlayersRoutes (s "players" </> (oneOf playersMatchers))
    , UrlParser.format SettingsRoutes (s "settings" </> (oneOf settingsMatchers))
    ]

financeMatchers : List (UrlParser.Parser (FinanceRoute -> a) a)
financeMatchers =
    [ UrlParser.format PaymentCheckRoutes (s "payments-check" </> (oneOf paymentsCheckMatchers))
    , UrlParser.format PaymentSystemRoutes (s "payment-system" </> (oneOf paymentSystemMatchers))
    , UrlParser.format InputReport (s "input-report" </> s "list")
    , UrlParser.format FundsFlow (s "finds-flow")
    , UrlParser.format MonthlyBalances (s "monthly-balances")
    ]

paymentsCheckMatchers : List (UrlParser.Parser (PaymentCheckRoute -> a) a)
paymentsCheckMatchers =
    [ UrlParser.format PaymentCheckList (s "list")
    , UrlParser.format PaymentCheckView (s "view" </> string)
    , UrlParser.format PaymentCheckCreate (s "create")
    ]

paymentSystemMatchers : List (UrlParser.Parser (PaymentSystemRoute -> a) a)
paymentSystemMatchers =
    [ UrlParser.format PaymentSystemList (s "list")
    , UrlParser.format PaymentSystemView (s "view" </> string)
    , UrlParser.format PaymentSystemCreate (s "create")
    ]

statisticMatchers : List (UrlParser.Parser (StatisticRoute -> a) a)
statisticMatchers =
    [ UrlParser.format ConsolidatedReport (s "consolidated-report")
    , UrlParser.format LtvReport (s "ltv-report")
    , UrlParser.format SegmentsReport (s "segments")
    , UrlParser.format RetentionsReport (s "retentions")
    , UrlParser.format ActivityWaves (s "waves")
    , UrlParser.format TimelineReport (s "timeline")
    , UrlParser.format CohortsReport (s "cohorts")
    ]

calendarMatchers : List (UrlParser.Parser (CalendarRoute -> a) a)
calendarMatchers =
    [ UrlParser.format EventsRoutes (s "event" </> (oneOf eventsMatchers))
    , UrlParser.format EventsTypesRoutes (s "event_type" </> (oneOf eventsTypesMatchers))
    , UrlParser.format EventsGroupsRoutes (s "event_group" </> (oneOf eventsGroupsMatchers))
    ]

eventsMatchers : List (UrlParser.Parser (EventsRoute -> a) a)
eventsMatchers =
    [ UrlParser.format EventsList (s "list")
    , UrlParser.format EventsEdit (s "edit" </> string)
    , UrlParser.format EventsCreate (s "create")
    ]

eventsTypesMatchers : List (UrlParser.Parser (EventsTypesRoute -> a) a)
eventsTypesMatchers =
    [ UrlParser.format EventsTypesList (s "list")
    , UrlParser.format EventsTypesEdit (s "edit" </> string)
    , UrlParser.format EventsTypesCreate (s "create")
    ]

eventsGroupsMatchers : List (UrlParser.Parser (EventsGroupsRoute -> a) a)
eventsGroupsMatchers =
    [ UrlParser.format EventsGroupsList (s "list")
    , UrlParser.format EventsGroupsEdit (s "edit" </> string)
    , UrlParser.format EventsGroupsCreate (s "create")
    ]

playersMatchers : List (UrlParser.Parser (PlayerRoute -> a) a)
playersMatchers =
    [ UrlParser.format Multiaccounts (s "multiaccounts")
    , UrlParser.format SignupChannelsRoutes (s "signup-channels" </> (oneOf signupChannelsMatchers))
    ]

signupChannelsMatchers : List (UrlParser.Parser (SignupChannelsRoute -> a) a)
signupChannelsMatchers =
    [ UrlParser.format SignupChannelList (s "list")
    , UrlParser.format SignupChannelEdit (s "edit" </> string)
    , UrlParser.format SignupChannelCreate (s "create")
    ]

settingsMatchers : List (UrlParser.Parser (SettingsRoute -> a) a)
settingsMatchers =
    [ UrlParser.format UserRoutes (s "user" </> (oneOf userMatchers))
    , UrlParser.format ProjectRoutes (s "project" </> (oneOf projectMatchers))
    , UrlParser.format NotificationRoutes (s "notification" </> (oneOf notificationMatchers))
    , UrlParser.format Permissions (s "permissions" </> s "index")
    , UrlParser.format DataSourceRoutes (s "data-source" </> (oneOf dataSourceMatchers))
    , UrlParser.format SmtpServerRoutes (s "smtp_server" </> (oneOf smtpServerMatchers))
    ]

userMatchers : List (UrlParser.Parser (UserRoute -> a) a)
userMatchers =
    [ UrlParser.format UserList (s "list")
    , UrlParser.format UserEdit (s "edit" </> string)
    , UrlParser.format UserCreate (s "create")
    ]

projectMatchers : List (UrlParser.Parser (ProjectRoute -> a) a)
projectMatchers =
    [ UrlParser.format ProjectList (s "list")
    , UrlParser.format ProjectEdit (s "edit" </> string)
    , UrlParser.format ProjectCreate (s "create")
    ]

notificationMatchers : List (UrlParser.Parser (NotificationRoute -> a) a)
notificationMatchers =
    [ UrlParser.format NotificationList (s "list")
    , UrlParser.format NotificationEdit (s "edit" </> string)
    , UrlParser.format NotificationCreate (s "create")
    ]

dataSourceMatchers : List (UrlParser.Parser (DataSourceRoute -> a) a)
dataSourceMatchers =
    [ UrlParser.format DataSourceList (s "list")
    , UrlParser.format DataSourceEdit (s "edit" </> string)
    , UrlParser.format DataSourceCreate (s "create")
    ]

smtpServerMatchers : List (UrlParser.Parser (SmtpServerRoute -> a) a)
smtpServerMatchers =
    [ UrlParser.format SmtpServerList (s "list")
    , UrlParser.format SmtpServerEdit (s "edit" </> string)
    , UrlParser.format SmtpServerCreate (s "create")
    ]

reverse : Route -> String
reverse route =
    case route of
        DashboardRoute ->
            ""

        LoginRoute ->
            "/login"

        FinanceRoutes subRoute ->
            "/finance" ++ reverseFinance subRoute

        StatisticRoutes subRoute ->
            "/statistics" ++ reverseStatistics subRoute

        CalendarRoutes subRoute ->
            "/event_calendar" ++ reverseCalendar subRoute

        PlayersRoutes subRoute ->
            "/players" ++ reversePlayers subRoute

        SettingsRoutes subRoute ->
            "/settings" ++ reverseSettings subRoute

        NotFoundRoute ->
            ""

reverseFinance : FinanceRoute -> String
reverseFinance route =
    case route of
        PaymentCheckRoutes subRoute ->
            "/payments-check/" ++ reversePaymentsCheck subRoute

        PaymentSystemRoutes subRoute ->
            "/payment-system/" ++ reversePaymentSystem subRoute

        InputReport ->
            "/input-report/list"

        FundsFlow ->
            "/finds-flow"

        MonthlyBalances ->
            "/monthly-balances"

reversePaymentsCheck : PaymentCheckRoute -> String
reversePaymentsCheck route =
    case route of
        PaymentCheckList ->
            "list"

        PaymentCheckView id ->
            "view/" ++ id

        PaymentCheckCreate ->
            "create"

reversePaymentSystem : PaymentSystemRoute -> String
reversePaymentSystem route =
    case route of
        PaymentSystemList ->
            "list"

        PaymentSystemView id ->
            "view/" ++ id

        PaymentSystemCreate ->
            "create"

reverseStatistics : StatisticRoute -> String
reverseStatistics route =
    case route of
        ConsolidatedReport ->
            "/consolidated-report"

        LtvReport ->
            "/ltv-report"

        SegmentsReport ->
            "/segments"

        RetentionsReport ->
            "/retentions"

        ActivityWaves ->
            "/waves"

        TimelineReport ->
            "/timeline"

        CohortsReport ->
            "/cohorts"

reverseCalendar : CalendarRoute -> String
reverseCalendar route =
    case route of
        EventsRoutes subRoute ->
            "/event/" ++ reverseEventsRoutes subRoute

        EventsTypesRoutes subRoute ->
            "/event_type/" ++ reverseEventsTypesRoutes subRoute

        EventsGroupsRoutes subRoute ->
            "/event_group/" ++ reverseEventsGroupsRoutes subRoute

reverseEventsRoutes : EventsRoute -> String
reverseEventsRoutes route =
    case route of
        EventsList ->
            "list"

        EventsEdit id ->
            "edit/" ++ id

        EventsCreate ->
            "create"

reverseEventsTypesRoutes : EventsTypesRoute -> String
reverseEventsTypesRoutes route =
    case route of
        EventsTypesList ->
            "list"

        EventsTypesEdit id ->
            "edit/" ++ id

        EventsTypesCreate ->
            "create"

reverseEventsGroupsRoutes : EventsGroupsRoute -> String
reverseEventsGroupsRoutes route =
    case route of
        EventsGroupsList ->
            "list"

        EventsGroupsEdit id ->
            "edit/" ++ id

        EventsGroupsCreate ->
            "create"

reversePlayers : PlayerRoute -> String
reversePlayers route =
    case route of
        Multiaccounts ->
            "/multiaccounts"

        SignupChannelsRoutes subRoute ->
            "/signup-channels/" ++ reverseSignupChannelsRoutes subRoute

reverseSignupChannelsRoutes : SignupChannelsRoute -> String
reverseSignupChannelsRoutes route =
    case route of
        SignupChannelList ->
            "list"

        SignupChannelEdit id ->
            "edit/" ++ id

        SignupChannelCreate ->
            "create"

reverseSettings : SettingsRoute -> String
reverseSettings route =
    case route of
        UserRoutes subRoute ->
            "/user/" ++ reverseUserRoutes subRoute

        ProjectRoutes subRoute ->
            "/project/" ++ reverseProjectRoutes subRoute

        NotificationRoutes subRoute ->
            "/notification/" ++ reverseNotificationRoutes subRoute

        Permissions ->
            "/permissions/index"

        DataSourceRoutes subRoute ->
            "/data-source/" ++ reverseDataSourceRoutes subRoute

        SmtpServerRoutes subRoute ->
            "/smtp_server/" ++ reverseSmtpServerRoutes subRoute

reverseUserRoutes : UserRoute -> String
reverseUserRoutes route =
    case route of
        UserList ->
            "list"

        UserEdit id ->
            "edit/" ++ id

        UserCreate ->
            "create"

reverseProjectRoutes : ProjectRoute -> String
reverseProjectRoutes route =
    case route of
        ProjectList ->
            "list"

        ProjectEdit id ->
            "edit/" ++ id

        ProjectCreate ->
            "create"

reverseNotificationRoutes : NotificationRoute -> String
reverseNotificationRoutes route =
    case route of
        NotificationList ->
            "list"

        NotificationEdit id ->
            "edit/" ++ id

        NotificationCreate ->
            "create"

reverseDataSourceRoutes : DataSourceRoute -> String
reverseDataSourceRoutes route =
    case route of
        DataSourceList ->
            "list"

        DataSourceEdit id ->
            "edit/" ++ id

        DataSourceCreate ->
            "create"

reverseSmtpServerRoutes : SmtpServerRoute -> String
reverseSmtpServerRoutes route =
    case route of
        SmtpServerList ->
            "list"

        SmtpServerEdit id ->
            "edit/" ++ id

        SmtpServerCreate ->
            "create"

getMenu : Route -> Maybe Menu
getMenu route =
    case route of
        FinanceRoutes _ -> Just Finance
        StatisticRoutes _ -> Just Statistics
        CalendarRoutes _ -> Just Calendar
        PlayersRoutes _ -> Just Players
        SettingsRoutes _ -> Just Settings
        _ -> Nothing

getMenuRoutings : Menu -> List Route
getMenuRoutings menu =
    case menu of
        Finance -> List.map FinanceRoutes financeRoutes
        Statistics -> List.map StatisticRoutes statisticRoutes
        Calendar -> List.map CalendarRoutes calendarRoutes
        Players -> List.map PlayersRoutes playersRoutes
        Settings -> List.map SettingsRoutes settingsRoutes

routeIsInMenu : Route -> Menu -> Bool
routeIsInMenu route menu =
    case route of
        FinanceRoutes _ -> menu == Finance
        StatisticRoutes _ -> menu == Statistics
        CalendarRoutes _ -> menu == Calendar
        PlayersRoutes _ -> menu == Players
        SettingsRoutes _ -> menu == Settings
        _ -> False

getRouteByTabIndex : Menu -> Int -> Maybe Route
getRouteByTabIndex menu i =
    case menu of
        Finance ->
            getFinanceRouteByIndex i

        Statistics ->
            getStatisticsRouteByIndex i

        Calendar ->
            getCalendarRouteByIndex i

        Players ->
            getPlayersRouteByIndex i

        Settings ->
            getSettingsRouteByIndex i

getFinanceRouteByIndex : Int -> Maybe Route
getFinanceRouteByIndex index =
    let
        maybeRoute = Array.fromList financeRoutes |> Array.get index
    in
        case maybeRoute of
            Nothing -> Nothing
            Just route -> Just <| FinanceRoutes route

getStatisticsRouteByIndex : Int -> Maybe Route
getStatisticsRouteByIndex index =
    let
        maybeRoute = Array.fromList statisticRoutes |> Array.get index
    in
        case maybeRoute of
            Nothing -> Nothing
            Just route -> Just <| StatisticRoutes route

getCalendarRouteByIndex : Int -> Maybe Route
getCalendarRouteByIndex index =
    let
        maybeRoute = Array.fromList calendarRoutes |> Array.get index
    in
        case maybeRoute of
            Nothing -> Nothing
            Just route -> Just <| CalendarRoutes route


getPlayersRouteByIndex : Int -> Maybe Route
getPlayersRouteByIndex index =
    let
        maybeRoute = Array.fromList playersRoutes |> Array.get index
    in
        case maybeRoute of
            Nothing -> Nothing
            Just route -> Just <| PlayersRoutes route

getSettingsRouteByIndex : Int -> Maybe Route
getSettingsRouteByIndex index =
    let
        maybeRoute = Array.fromList settingsRoutes |> Array.get index
    in
        case maybeRoute of
            Nothing -> Nothing
            Just route -> Just <| SettingsRoutes route
