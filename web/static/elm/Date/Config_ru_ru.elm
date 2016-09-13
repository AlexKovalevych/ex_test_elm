module Date.Config_ru_ru exposing (..)

import Date
import Date.Extra.Config as Config
import Date.I18n.I_ru_ru as Russian

config : Config.Config
config =
    { i18n =
        { dayShort = Russian.dayShort
        , dayName = Russian.dayName
        , monthShort = Russian.monthShort
        , monthName = Russian.monthName
        , dayOfMonthWithSuffix = Russian.dayOfMonthWithSuffix
        }
    , format =
        { date = "%-d/%m/%Y" -- d/MM/yyyy
        , longDate = "%A, %-d %B %Y" -- dddd, d MMMM yyyy
        , time = "%-I:%M %p" -- h:mm tt
        , longTime = "%-I:%M:%S %p" -- h:mm:ss tt
        , dateTime = "%-d/%m/%Y %-I:%M %p"  -- date + time
        , firstDayOfWeek = Date.Mon
        }
    }
