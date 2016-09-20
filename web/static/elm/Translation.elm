module Translation exposing
    ( Language (..)
    , TranslationId (..)
    , translate
    , getDateConfig
    )

import Date.Extra.Config as Config
import Date.Extra.Format exposing (format, isoTimeFormat)
import Date.Extra.Config.Config_en_au as EnConfig exposing (config)
import Date.Config_ru_ru as RuConfig exposing (config)
import Date

type alias TranslationSet =
    { english : String
    , russian : String
    }

type TranslationId
    = Login String
    --| Validation String
    | SmsSent String
    | Ru
    | En
    | Exit
    | ServerTime Int
    | Menu String
    | Dashboard String
    --| PaymentCheck String
    --| PaymentSystem String
    --| InputReport String
    --| FundsFlow String
    --| MonthlyBalances String
    | Empty

type Language
    = English
    | Russian

getDateConfig : Language -> Config.Config
getDateConfig lang =
    case lang of
        English -> EnConfig.config
        Russian -> RuConfig.config

translate : Language -> TranslationId -> String
translate lang trans =
    let
        translationSet =
        case trans of
            Login msg -> case msg of
                "email" -> TranslationSet "Email" "Email"
                "password" -> TranslationSet "Password" "Пароль"
                "invalid_email_password" -> TranslationSet "Invalid email or password" "Неправильный логин или пароль"
                "invalid_sms_code" -> TranslationSet "Invalid sms code" "Неправильный код из SMS"
                "invalid_google_code" -> TranslationSet "Invalid code" "Неправильный код"
                "disabled" -> TranslationSet "Your account is disabled. Contact system administrator" "Ваш аккаунт отключен. Свяжитесь с администратором"
                "sms_was_sent" -> TranslationSet "SMS was sent" "SMS было отправлено"
                "sms_was_not_sent" -> TranslationSet "Failed to send SMS" "Ошибка при отправке SMS"
                "submit" -> TranslationSet "Login" "Войти"
                "sms_code" -> TranslationSet "SMS code" "SMS код"
                "google_code" -> TranslationSet "Authentication code" "Код аутентификации"
                "resend_sms" -> TranslationSet "Send SMS again" "Отправить SMS еще раз"
                _ -> TranslationSet "" ""

            --Validation msg -> case msg of
            --    _ -> TranslationSet "" ""

            Menu msg -> case msg of
                "dashboard" -> TranslationSet "Project indicators" "Показатели проектов"
                "finance" -> TranslationSet "Finance" "Финансы"
                "statistics" -> TranslationSet "Statistics" "Статистика"
                "calendar_events" -> TranslationSet "Events calendar" "Календарь событий"
                "players" -> TranslationSet "Players" "Игроки"
                "settings" -> TranslationSet "Settings" "Настройки"
                "PaymentCheckRoutes PaymentCheckList" -> TranslationSet "Payments check" "Сверка платежей"
                "PaymentSystemRoutes PaymentSystemList" -> TranslationSet "PS Config" "Конфиг ПС"
                "MonthlyBalances" -> TranslationSet "Monthly balance" "Месячные балансы"
                "InputReport" -> TranslationSet "Incoming reports" "Входящие отчеты"
                "FundsFlow" -> TranslationSet "Funds flow" "Движение средств"
                "TimelineReport" -> TranslationSet "Timeline report" "Таймлайн отчет"
                "SegmentsReport" -> TranslationSet "Segments report" "Отчет по сегментам"
                "RetentionsReport" -> TranslationSet "Retention" "Ретеншены"
                "LtvReport" -> TranslationSet "LTV report" "LTV отчет"
                "ConsolidatedReport" -> TranslationSet "Consolidated report" "Сводный отчет"
                "CohortsReport" -> TranslationSet "Cohorts report" "Отчет по когортам"
                "ActivityWaves" -> TranslationSet "Activity waves" "Всплески активности"
                "EventsTypesRoutes EventsTypesList" -> TranslationSet "Events types list" "Типы событий"
                "EventsRoutes EventsList" -> TranslationSet "Events list" "Список событий"
                "EventsGroupsRoutes EventsGroupsList" -> TranslationSet "Events groups list" "Группы событий"
                "SignupChannelsRoutes SignupChannelList" -> TranslationSet "Signup channels" "Каналы регистрации"
                "Multiaccounts" -> TranslationSet "Multiaccounts" "Мультиаккаунты"
                "UserRoutes UserList" -> TranslationSet "Users" "Пользователи"
                "ProjectRoutes ProjectList" -> TranslationSet "Projects" "Проекты"
                "NotificationRoutes NotificationList" -> TranslationSet "Notifications" "Оповещения"
                "Permissions" -> TranslationSet "Permissions" "Права доступа"
                "DataSourceRoutes DataSourceList" -> TranslationSet "Data sources" "Источники данных"
                "SmtpServerRoutes SmtpServerList" -> TranslationSet "SMTP server" "SMTP сервера"
                _ -> TranslationSet "" ""

            Dashboard msg -> case msg of
                "inout" -> TranslationSet "Inout" "Inout"
                "deposits" -> TranslationSet "Deposits" "Депозиты"
                "withdrawal" -> TranslationSet "Withdrawal" "Выплаты"
                "netgaming" -> TranslationSet "Netgaming" "Netgaming"
                "bets" -> TranslationSet "Bets" "Ставки"
                "wins" -> TranslationSet "Wins" "Выигрыши"
                "projects_type" -> TranslationSet "Projects:" "Проекты:"
                "default_projects" -> TranslationSet "Our" "Наши"
                "partner_projects" -> TranslationSet "Partner" "Партнерские"
                "sort_by" -> TranslationSet "Sort by:" "Сортировать по:"
                "sort_by_PaymentsAmount" -> TranslationSet "Inout" "Inout"
                "sort_by_DepositsAmount" -> TranslationSet "Deposits" "Депозитам"
                "sort_by_CashoutsAmount" -> TranslationSet "Withdrawals" "Выплатам"
                "sort_by_NetgamingAmount" -> TranslationSet "Netgaming" "Netgaming"
                "sort_by_BetsAmount" -> TranslationSet "Bets" "Ставкам"
                "sort_by_WinsAmount" -> TranslationSet "Wins" "Выигрышам"
                "sort_by_FirstDepositsAmount" -> TranslationSet "First deposits amount" "Сумме первых депозитов"
                "period" -> TranslationSet "Period:" "Период:"
                "compare_period" -> TranslationSet "Compare period:" "Период сравнения:"
                "period_month" -> TranslationSet "Month to date" "С начала месяца"
                "period_year" -> TranslationSet "Year to date" "С начала года"
                "period_days30" -> TranslationSet "Last 30 days" "Последние 30 дней"
                "period_months12" -> TranslationSet "Last 12 months" "Последние 12 месяцев"
                "total" -> TranslationSet "Total" "Всего"
                "current" -> TranslationSet "Current" "Текущий"
                "previous" -> TranslationSet "Previous" "Предыдущий"
                _ -> TranslationSet "" ""

            --PaymentCheck msg -> case msg of
            --    "title" -> TranslationSet "Generated reports" "Созданные отчеты"
            --    _ -> TranslationSet "" ""

            --PaymentSystem msg -> case msg of
            --    "title" -> TranslationSet "Generated reports" "Созданные отчеты"
            --    _ -> TranslationSet "" ""

            --InputReport msg -> case msg of
            --    "title" -> TranslationSet "Incoming reports" "Входящие отчеты"
            --    _ -> TranslationSet "" ""

            --FundsFlow msg -> case msg of
            --    "title" -> TranslationSet "Funds flow" "Движение средств"
            --    _ -> TranslationSet "" ""

            --MonthlyBalances msg -> case msg of
            --    "title" -> TranslationSet "Monthly balance" "Месячные балансы"
            --    _ -> TranslationSet "" ""

            Ru ->
                TranslationSet "Русский" "Русский"

            En ->
                TranslationSet "English" "English"

            SmsSent phoneNumber ->
                TranslationSet
                    ("SMS with confirmation code was sent to your phone number (" ++ phoneNumber ++ "). Please contact site administration if you didn\'t receive it.")
                    ("На ваш номер (" ++ phoneNumber ++ ") отправлено сообщение с кодом подтверждения. Если вы не получили код, обратитесь к администрации.")

            ServerTime time ->
                let
                    formattedTime = format (getDateConfig lang) isoTimeFormat (Date.fromTime <| toFloat time)
                in
                    TranslationSet
                        ("Warning! Generated code is sensitive to the time set at your phone. Maximum difference with server time may be ± 1 minute. Server time: " ++ formattedTime)
                        ("Внимание! Код, генерируемый вашим телефоном, чувствителен ко времени, установленном в телефоне. Максимальная разница с серверным временем может быть ± 1 минуту. Серверное время: " ++ formattedTime)

            Exit ->
                TranslationSet "Exit" "Выйти"

            Empty ->
                TranslationSet "" ""

    in
        case lang of
            English ->
                .english translationSet
            Russian ->
                .russian translationSet
