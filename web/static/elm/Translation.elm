module Translation exposing
    ( Language (..)
    , TranslationId (..)
    , translate
    )

import Date.Format exposing(format)
import Date

type alias TranslationSet =
    { english : String
    , russian : String
    }

type TranslationId
    = Email
    | Login
    | Password
    | Validation String
    | SmsSent String
    | RU
    | EN
    | ServerTime Int
    | SmsCode
    | ResendSms
    | SmsWasSent
    | GoogleCode
    | Menu String

type Language
    = English
    | Russian

translate : Language -> TranslationId -> String
translate lang trans =
    let
        translationSet =
        case trans of
            Email ->
                TranslationSet "Email" "Email"

            Password ->
                TranslationSet "Password" "Пароль"

            Validation msg -> case msg of
                "invalid_email_password" -> TranslationSet "Invalid email or password" "Неправильный логин или пароль"
                "invalid_sms_code" -> TranslationSet "Invalid sms code" "Неправильный код из SMS"
                "invalid_google_code" -> TranslationSet "Invalid code" "Неправильный код"
                "disabled" -> TranslationSet "Your account is disabled. Contact system administrator" "Ваш аккаунт отключен. Свяжитесь с администратором"
                _ -> TranslationSet "" ""

            Menu msg -> case msg of
                "dashboard" -> TranslationSet "Project indicators" "Показатели проектов"
                "finance" -> TranslationSet "Finance" "Финансы"
                "statistics" -> TranslationSet "Statistics" "Статистика"
                "calendar_events" -> TranslationSet "Events calendar" "Календарь событий"
                "players" -> TranslationSet "Players" "Игроки"
                "settings" -> TranslationSet "Settings" "Настройки"
                "payments_check" -> TranslationSet "Payments check" "Сверка платежей"
                "payment_systems" -> TranslationSet "PS Config" "Конфиг ПС"
                "monthly_balance" -> TranslationSet "Monthly balance" "Месячные балансы"
                "incoming_reports" -> TranslationSet "Incoming reports" "Входящие отчеты"
                "funds_flow" -> TranslationSet "Funds flow" "Движение средств"
                "timeline_report" -> TranslationSet "Timeline report" "Таймлайн отчет"
                "segments_report" -> TranslationSet "Segments report" "Отчет по сегментам"
                "retention" -> TranslationSet "Retention" "Ретеншены"
                "ltv_report" -> TranslationSet "LTV report" "LTV отчет"
                "consolidated_report" -> TranslationSet "Consolidated report" "Сводный отчет"
                "cohorts_report" -> TranslationSet "Cohorts report" "Отчет по когортам"
                "activity_waves" -> TranslationSet "Activity waves" "Всплески активности"
                "events_types_list" -> TranslationSet "Events types list" "Типы событий"
                "events_list" -> TranslationSet "Events list" "Список событий"
                "events_groups_list" -> TranslationSet "Events groups list" "Группы событий"
                "signup_channels" -> TranslationSet "Signup channels" "Каналы регистрации"
                "multiaccounts" -> TranslationSet "Multiaccounts" "Мультиаккаунты"
                "user" -> TranslationSet "Users" "Пользователи"
                "project" -> TranslationSet "Projects" "Проекты"
                "notification" -> TranslationSet "Notifications" "Оповещения"
                "permissions" -> TranslationSet "Permissions" "Права доступа"
                "data_source" -> TranslationSet "Data sources" "Источники данных"
                "smtp_server" -> TranslationSet "SMTP server" "SMTP сервера"
                _ -> TranslationSet "" ""

            Login ->
                TranslationSet "Login" "Войти"

            RU ->
                TranslationSet "Russian" "Русский"

            EN ->
                TranslationSet "English" "Английский"

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

            SmsCode ->
                TranslationSet "SMS code" "SMS код"

            GoogleCode ->
                TranslationSet "Authentication code" "Код аутентификации"

            ResendSms ->
                TranslationSet "Send SMS again" "Отправить SMS еще раз"

            SmsWasSent ->
                TranslationSet "SMS was sent" "SMS было отправлено"
    in
        case lang of
            English ->
                .english translationSet
            Russian ->
                .russian translationSet
