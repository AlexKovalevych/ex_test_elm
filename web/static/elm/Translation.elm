module Translation exposing
    ( Language (..)
    , TranslationId (..)
    , translate
    )

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
                let time = toString(time)
                in TranslationSet
                    ("Warning! Generated code is sensitive to the time set at your phone. Maximum difference with server time may be ± 1 minute. Server time: " ++ time)
                    ("Внимание! Код, генерируемый вашим телефоном, чувствителен ко времени, установленном в телефоне. Максимальная разница с серверным временем может быть ± 1 минуту. Серверное время: " ++ time)
    in
        case lang of
            English ->
                .english translationSet
            Russian ->
                .russian translationSet
