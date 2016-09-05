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
    | RU
    | EN

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
    in
        case lang of
            English ->
                .english translationSet
            Russian ->
                .russian translationSet
