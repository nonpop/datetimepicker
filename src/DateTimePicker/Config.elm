module DateTimePicker.Config
    exposing
        ( Config
        , CssConfig
        , DatePickerConfig
        , I18n
        , InputFormat
        , NameOfDays
        , TimePickerConfig
        , TimePickerType(..)
        , Type(..)
        , defaultDateI18n
        , defaultDateInputFormat
        , defaultDatePickerConfig
        , defaultDateTimeI18n
        , defaultDateTimeInputFormat
        , defaultDateTimePickerConfig
        , defaultNamespace
        , defaultTimeI18n
        , defaultTimePickerConfig
        )

{-| DateTimePicker configuration


# Configuration

@docs Config, I18n, InputFormat, DatePickerConfig, TimePickerConfig, NameOfDays, TimePickerType, Type, CssConfig


# Default Configuration

@docs defaultDatePickerConfig, defaultTimePickerConfig, defaultDateTimePickerConfig, defaultDateI18n, defaultTimeI18n, defaultDateTimeI18n, defaultDateInputFormat, defaultDateTimeInputFormat, defaultNamespace

-}

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import DateParser
import DateTimePicker.Formatter
import DateTimePicker.Internal exposing (InternalState)
import Html
import Html.Attributes


type alias State =
    InternalState


{-| The type of picker (for Internal Use)
-}
type Type msg className
    = DateType (Config (CssConfig (DatePickerConfig {}) msg className) msg)
    | DateTimeType (Config (CssConfig (DatePickerConfig TimePickerConfig) msg className) msg)
    | TimeType (Config (CssConfig TimePickerConfig msg className) msg)


{-| Configuration

  - `onChange` is the message for when the selected value and internal `State` in the date picker has changed.
  - `autoClose` is a flag to indicate whether the dialog should be automatically closed when a date and/or time is selected.
  - `i18n` is internationalization configuration.

-}
type alias Config otherConfig msg =
    { otherConfig
        | onChange : State -> Maybe Date -> msg
        , autoClose : Bool
        , i18n : I18n
        , usePicker : Bool
        , attributes : List (Html.Attribute msg)
    }


{-| CSS Function Configuration

  - `class` is a function that turn a list of CSS Classes into an `Html.Attribute`

-}
type alias CssConfig otherConfig msg className =
    { otherConfig
        | class : List className -> Html.Attribute msg
    }


{-| Internationalization configuration

  - `footerFormatter` is a Date to string formatter used to display the date in the footer section.
  - `titleFormatter` is a Date to string formatter used to display the date in the title section.
  - `timeTitleFormatter` is a Date to string formatter used to display the time in the title section.
  - `inputFormat` is an input date formatter and parser.

-}
type alias I18n =
    { titleFormatter : Date -> String
    , footerFormatter : Date -> String
    , timeTitleFormatter : Date -> String
    , inputFormat : InputFormat
    }


{-| Configuration for the DatePicker

  - `nameOfDays` is the configuration for name of days in a week.
  - `firstDayOfWeek` is the first day of the week.
  - `weekNumbers` show/hide week numbers
  - `titleFormatter` is the Date to String formatter for the dialog's title.
  - `footerFormatter` is the Date to String formatter for the dialog's footer.
  - `allowYearNavigation` show/hide year navigation button.

-}
type alias DatePickerConfig otherConfig =
    { otherConfig
        | nameOfDays : NameOfDays
        , firstDayOfWeek : Date.Day
        , weekNumbers : Bool
        , allowYearNavigation : Bool
    }


{-| Input formatter and parser

  - `inputFormatter` is a Date to string formatter used to display the date in the input text
  - `inputParser` is a String to Date parser used to parsed input text into Date

-}
type alias InputFormat =
    { inputFormatter : Date -> String
    , inputParser : String -> Maybe Date
    }


{-| Default Date internationalization

  - `titleFormatter` Default: `"%B %Y"`
  - `footerFormatter` Default: `"%A, %B %d, %Y"`
  - `inputFormat` Default: "%m/%d/%Y"

-}
defaultDateI18n : I18n
defaultDateI18n =
    { titleFormatter = DateTimePicker.Formatter.titleFormatter
    , footerFormatter = DateTimePicker.Formatter.footerFormatter
    , timeTitleFormatter = DateTimePicker.Formatter.timeFormatter
    , inputFormat = defaultDateInputFormat
    }


{-| Default Time internationalization

  - `titleFormatter` Default: `"%B %Y"`
  - `footerFormatter` Default: `"%A, %B %d, %Y"`
  - `inputFormat` Default: "%I:%M %p"

-}
defaultTimeI18n : I18n
defaultTimeI18n =
    { titleFormatter = DateTimePicker.Formatter.titleFormatter
    , footerFormatter = DateTimePicker.Formatter.footerFormatter
    , timeTitleFormatter = DateTimePicker.Formatter.timeFormatter
    , inputFormat = defaultTimeInputFormat
    }


{-| Default Date and Time internationalization

  - `titleFormatter` Default: `"%B %Y"`
  - `footerFormatter` Default: `"%A, %B %d, %Y"`
  - `inputFormat` Default: "%m/%d/%Y %I:%M %p"

-}
defaultDateTimeI18n : I18n
defaultDateTimeI18n =
    { titleFormatter = DateTimePicker.Formatter.titleFormatter
    , footerFormatter = DateTimePicker.Formatter.footerFormatter
    , timeTitleFormatter = DateTimePicker.Formatter.timeFormatter
    , inputFormat = defaultDateTimeInputFormat
    }


{-| Default input format for date picker
-}
defaultDateInputFormat : InputFormat
defaultDateInputFormat =
    { inputFormatter = DateTimePicker.Formatter.dateFormatter
    , inputParser =
        \input ->
            input
                |> DateParser.parse config DateTimePicker.Formatter.datePattern
                |> Result.toMaybe
                |> Maybe.map Just
                |> Maybe.withDefault (Date.fromString input |> Result.toMaybe)
    }


{-| Default input format for date and time picker
-}
defaultDateTimeInputFormat : InputFormat
defaultDateTimeInputFormat =
    { inputFormatter = DateTimePicker.Formatter.dateTimeFormatter
    , inputParser =
        \input ->
            input
                |> DateParser.parse config DateTimePicker.Formatter.dateTimePattern
                |> Result.toMaybe
                |> Maybe.map Just
                |> Maybe.withDefault (Date.fromString input |> Result.toMaybe)
    }


{-| Default input format for time picker
-}
defaultTimeInputFormat : InputFormat
defaultTimeInputFormat =
    { inputFormatter = DateTimePicker.Formatter.timeFormatter
    , inputParser =
        \input ->
            input
                |> DateParser.parse config DateTimePicker.Formatter.timePattern
                |> Result.toMaybe
    }


{-| Configuration for TimePicker

  - `timePickerType` is the type of the time picker, either Analog or Digital

-}
type alias TimePickerConfig =
    { timePickerType : TimePickerType
    }


{-| The type of time picker, can be either Digital or Analog
-}
type TimePickerType
    = Digital
    | Analog


{-| Default configuration for DatePicker

  - `onChange` No Default
  - `autoClose` Default: True
  - `nameOfDays` see `NameOfDays` for the default values.
  - `firstDayOfWeek` Default: Sunday.
  - `weekNumbers` Default: False
  - `allowYearNavigation` Default : True

-}
defaultDatePickerConfig : (State -> Maybe Date -> msg) -> Config (CssConfig (DatePickerConfig {}) msg className) msg
defaultDatePickerConfig onChange =
    { onChange = onChange
    , autoClose = True
    , nameOfDays = defaultNameOfDays
    , firstDayOfWeek = Date.Sun
    , weekNumbers = False
    , allowYearNavigation = True
    , i18n = defaultDateI18n
    , usePicker = True
    , attributes = []
    , class = defaultClass
    }


{-| Default configuration for TimePicker

  - `onChange` No Default
  - `dateFormatter` Default: `"%m/%d/%Y"`
  - `dateTimeFormatter` Default: `"%m/%d/%Y %I:%M %p"`
  - `autoClose` Default: False
  - `timeFormatter` Default: `"%I:%M %p"`
  - `timePickerType` Default: Analog

-}
defaultTimePickerConfig : (State -> Maybe Date -> msg) -> Config (CssConfig TimePickerConfig msg className) msg
defaultTimePickerConfig onChange =
    { onChange = onChange
    , autoClose = False
    , timePickerType = Analog
    , i18n = defaultTimeI18n
    , usePicker = True
    , attributes = []
    , class = defaultClass
    }


{-| Default configuration for DateTimePicker

  - `onChange` No Default
  - `dateFormatter` Default: `"%m/%d/%Y"`
  - `dateTimeFormatter` Default: `"%m/%d/%Y %I:%M %p"`
  - `autoClose` Default: False
  - `nameOfDays` see `NameOfDays` for the default values.
  - `firstDayOfWeek` Default: Sunday.
  - `weekNumbers` Default: False.
  - `titleFormatter` Default: `"%B %Y"`
  - `fullDateFormatter` Default: `"%A, %B %d, %Y"`
  - `timeFormatter` Default: `"%I:%M %p"`
  - `timePickerType` Default: Analog
  - `allowYearNavigation` Default : True

-}
defaultDateTimePickerConfig : (State -> Maybe Date -> msg) -> Config (CssConfig (DatePickerConfig TimePickerConfig) msg className) msg
defaultDateTimePickerConfig onChange =
    { onChange = onChange
    , autoClose = False
    , nameOfDays = defaultNameOfDays
    , firstDayOfWeek = Date.Sun
    , weekNumbers = False
    , timePickerType = Analog
    , allowYearNavigation = True
    , i18n = defaultDateTimeI18n
    , usePicker = True
    , attributes = []
    , class = defaultClass
    }


{-| Configuration for name of days in a week.

This will be displayed as the calendar's header.
Default:

  - sunday = "Su"
  - monday = "Mo"
  - tuesday = "Tu"
  - wednesday = "We"
  - thursday = "Th"
  - friday = "Fr"
  - saturday = "Sa"

-}
type alias NameOfDays =
    { sunday : String
    , monday : String
    , tuesday : String
    , wednesday : String
    , thursday : String
    , friday : String
    , saturday : String
    }


defaultNameOfDays : NameOfDays
defaultNameOfDays =
    { sunday = "Su"
    , monday = "Mo"
    , tuesday = "Tu"
    , wednesday = "We"
    , thursday = "Th"
    , friday = "Fr"
    , saturday = "Sa"
    }


defaultClass : List a -> Html.Attribute msg
defaultClass classes =
    classes
        |> List.map (\class -> ( defaultNamespace ++ toString class, True ))
        |> Html.Attributes.classList


{-| Default CSS Namespace
-}
defaultNamespace : String
defaultNamespace =
    "elm-input-datepicker"
