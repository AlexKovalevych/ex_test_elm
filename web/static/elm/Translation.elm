module Translation exposing
    ( Language (..)
    , TranslationId (..)
    , translate
    )

import Date.Format exposing (format)
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
                "projects_type" -> TranslationSet "Projects:" "Проекты:"
                "default_projects" -> TranslationSet "Our" "Наши"
                "partner_projects" -> TranslationSet "Partner" "Партнерские"
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
                    formattedTime = format "%H:%M:%S" (Date.fromTime <| toFloat time)
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
