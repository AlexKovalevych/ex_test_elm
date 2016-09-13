module Date.I18n.I_ru_ru exposing (..)

import Date exposing (Day (..), Month (..))
import String exposing (padLeft)

{-| Day short name. -}
dayShort : Day -> String
dayShort day =
  case day of
    Mon -> "Пон"
    Tue -> "Вто"
    Wed -> "Сре"
    Thu -> "Чет"
    Fri -> "Пят"
    Sat -> "Суб"
    Sun -> "Вос"


{-| Day full name. -}
dayName : Day -> String
dayName day =
  case day of
    Mon -> "Понедельник"
    Tue -> "Вторник"
    Wed -> "Среда"
    Thu -> "Четверг"
    Fri -> "Пятница"
    Sat -> "Суббота"
    Sun -> "Воскресенье"


{-| Month short name. -}
monthShort : Month -> String
monthShort month =
  case month of
    Jan -> "Янв"
    Feb -> "Фев"
    Mar -> "Мар"
    Apr -> "Апр"
    May -> "Май"
    Jun -> "Июн"
    Jul -> "Июл"
    Aug -> "Авг"
    Sep -> "Сен"
    Oct -> "Окт"
    Nov -> "Ноя"
    Dec -> "Дек"


{-| Month full name. -}
monthName : Month -> String
monthName month =
  case month of
    Jan -> "Январь"
    Feb -> "Февраль"
    Mar -> "Март"
    Apr -> "Апрель"
    May -> "Май"
    Jun -> "Июнь"
    Jul -> "Июль"
    Aug -> "Август"
    Sep -> "Сентябрь"
    Oct -> "Октябрь"
    Nov -> "Ноябрь"
    Dec -> "Декабрь"


{-| Returns a common english idiom for days of month.
Pad indicates space pad the day of month value so single
digit outputs have space padding to make them same
length as double digit days of monnth.
-}
dayOfMonthWithSuffix : Bool -> Int -> String
dayOfMonthWithSuffix pad day =
  let
    value =
      case day of
        1 -> "1-й"
        21 -> "21-й"
        2 -> "2-й"
        22 -> "22-й"
        3 -> "3-й"
        23 -> "23-й"
        31 -> "31-й"
        _ -> (toString day) ++ "й"
  in
    if pad then
      padLeft 4 ' ' value
    else
      value
