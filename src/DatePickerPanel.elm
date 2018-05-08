module DatePickerPanel exposing (Config, view)

import Date exposing (Date)
import Date.Extra.Config.Config_en_us
import Date.Extra.Core
import Date.Extra.Duration
import Date.Extra.Format
import DateTimePicker.Config exposing (Config, CssConfig, DatePickerConfig, NameOfDays, TimePickerConfig, TimePickerType(..), Type(..), defaultDatePickerConfig, defaultDateTimePickerConfig, defaultTimePickerConfig)
import DateTimePicker.DateUtils
import DateTimePicker.Events exposing (onBlurWithChange, onMouseDownPreventDefault, onMouseUpPreventDefault, onTouchEndPreventDefault, onTouchStartPreventDefault)
import DateTimePicker.Internal exposing (InternalState(..), Time)
import DateTimePicker.SharedStyles exposing (CssClasses(..))
import DateTimePicker.Svg
import Html exposing (..)
import Html.Attributes exposing (value)
import List.Extra
import String.Extra


type alias State =
    InternalState


type alias Config otherConfig msg =
    { otherConfig
        | onChange : State -> Maybe Date -> msg
        , nameOfDays : NameOfDays
        , firstDayOfWeek : Date.Day
        , weekNumbers : Bool
        , weekNumberPrefix : String
        , allowYearNavigation : Bool
        , titleFormatter : Date -> String
        , footerFormatter : Date -> String
    }



-- ACTIONS


switchMode : State -> State
switchMode (InternalState state) =
    InternalState { state | event = "title" }


gotoNextMonth : State -> State
gotoNextMonth (InternalState state) =
    let
        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Month 1) state.titleDate
    in
        InternalState
            { state
                | event = "next"
                , titleDate = updatedTitleDate
            }


gotoNextYear : State -> State
gotoNextYear (InternalState state) =
    let
        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Year 1) state.titleDate
    in
        InternalState
            { state
                | event = "nextYear"
                , titleDate = updatedTitleDate
            }


gotoPreviousMonth : State -> State
gotoPreviousMonth (InternalState state) =
    let
        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Month -1) state.titleDate
    in
        InternalState
            { state
                | event = "previous"
                , titleDate = updatedTitleDate
            }


gotoPreviousYear : State -> State
gotoPreviousYear (InternalState state) =
    let
        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Year -1) state.titleDate
    in
        InternalState
            { state
                | event = "previousYear"
                , titleDate = updatedTitleDate
            }



-- VIEWS


view : Config (CssConfig a msg CssClasses) msg -> State -> Maybe Date -> Html msg
view config ((InternalState stateValue) as state) currentDate =
    div [ config.class [ DatePickerDialog ] ]
        [ div [ config.class [ Header ] ]
            (navigation config state currentDate)
        , calendar config state currentDate
        , div
            [ config.class [ Footer ] ]
            [ stateValue.date |> Maybe.map config.footerFormatter |> Maybe.withDefault "--" |> text ]
        ]


navigation : Config (CssConfig a msg CssClasses) msg -> State -> Maybe Date.Date -> List (Html msg)
navigation config state currentDate =
    [ previousYearButton config state currentDate
    , previousButton config state currentDate
    , title config state currentDate
    , nextButton config state currentDate
    , nextYearButton config state currentDate
    ]


title : Config (CssConfig a msg CssClasses) msg -> State -> Maybe Date.Date -> Html msg
title config ((InternalState stateValue) as state) currentDate =
    let
        date =
            stateValue.titleDate
    in
        span
            [ config.class [ Title ]
            , onMouseDownPreventDefault <| config.onChange (switchMode state) currentDate
            ]
            [ date
                |> Maybe.map config.titleFormatter
                |> Maybe.withDefault "N/A"
                |> text
            ]


previousYearButton : Config (CssConfig a msg CssClasses) msg -> State -> Maybe Date.Date -> Html msg
previousYearButton config state currentDate =
    if config.allowYearNavigation then
        span
            [ config.class [ DoubleArrowLeft ]
            , onMouseDownPreventDefault <| config.onChange (gotoPreviousYear state) currentDate
            , onTouchStartPreventDefault <| config.onChange (gotoPreviousYear state) currentDate
            ]
            [ DateTimePicker.Svg.doubleLeftArrow ]
    else
        Html.text ""


noYearNavigationClass : Config (CssConfig a msg CssClasses) msg -> List CssClasses
noYearNavigationClass config =
    if config.allowYearNavigation then
        []
    else
        [ NoYearNavigation ]


previousButton : Config (CssConfig a msg CssClasses) msg -> State -> Maybe Date.Date -> Html msg
previousButton config state currentDate =
    span
        [ config.class <| ArrowLeft :: noYearNavigationClass config
        , onMouseDownPreventDefault <| config.onChange (gotoPreviousMonth state) currentDate
        , onTouchStartPreventDefault <| config.onChange (gotoPreviousMonth state) currentDate
        ]
        [ DateTimePicker.Svg.leftArrow ]


nextButton : Config (CssConfig a msg CssClasses) msg -> State -> Maybe Date.Date -> Html msg
nextButton config state currentDate =
    span
        [ config.class <| ArrowRight :: noYearNavigationClass config
        , onMouseDownPreventDefault <| config.onChange (gotoNextMonth state) currentDate
        , onTouchStartPreventDefault <| config.onChange (gotoNextMonth state) currentDate
        ]
        [ DateTimePicker.Svg.rightArrow ]


nextYearButton : Config (CssConfig a msg CssClasses) msg -> State -> Maybe Date.Date -> Html msg
nextYearButton config state currentDate =
    if config.allowYearNavigation then
        span
            [ config.class [ DoubleArrowRight ]
            , onMouseDownPreventDefault <| config.onChange (gotoNextYear state) currentDate
            , onTouchStartPreventDefault <| config.onChange (gotoNextYear state) currentDate
            ]
            [ DateTimePicker.Svg.doubleRightArrow ]
    else
        Html.text ""


calendar : Config (CssConfig a msg CssClasses) msg -> State -> Maybe Date.Date -> Html msg
calendar config (InternalState state) currentDate =
    case state.titleDate of
        Nothing ->
            Html.text ""

        Just titleDate ->
            let
                firstDay =
                    Date.Extra.Core.toFirstOfMonth titleDate
                        |> Date.dayOfWeek
                        |> DateTimePicker.DateUtils.dayToInt config.firstDayOfWeek

                month =
                    Date.month titleDate

                year =
                    Date.year titleDate

                daysAndWeeks =
                    DateTimePicker.DateUtils.generateCalendar config.firstDayOfWeek month year

                header =
                    thead [ config.class [ DaysOfWeek ] ]
                        [ tr
                            []
                            (dayNames config)
                        ]

                isHighlighted day =
                    state.date
                        |> Maybe.map (\current -> day.day == Date.day current && month == Date.month current && year == Date.year current)
                        |> Maybe.withDefault False

                isToday day =
                    state.today
                        |> Maybe.map (\today -> day.day == Date.day today && month == Date.month today && year == Date.year today)
                        |> Maybe.withDefault False

                toCell day =
                    let
                        selectedDate =
                            DateTimePicker.DateUtils.toDate year month day
                    in
                        td
                            [ config.class
                                (case day.monthType of
                                    DateTimePicker.DateUtils.Previous ->
                                        [ PreviousMonth ]

                                    DateTimePicker.DateUtils.Current ->
                                        CurrentMonth
                                            :: (if isHighlighted day then
                                                    [ SelectedDate ]
                                                else if isToday day then
                                                    [ Today ]
                                                else
                                                    []
                                               )

                                    DateTimePicker.DateUtils.Next ->
                                        [ NextMonth ]
                                )
                            , Html.Attributes.attribute "role" "button"
                            , Html.Attributes.attribute "aria-label" (Date.Extra.Format.format Date.Extra.Config.Config_en_us.config "%e, %A %B %Y" selectedDate)
                            , onMouseDownPreventDefault <| dateClickHandler config (InternalState state) year month day
                            , onTouchStartPreventDefault <| dateClickHandler config (InternalState state) year month day
                            ]
                            [ text <| toString day.day ]

                weekNumberCell weekNumber =
                    td [ config.class [ WeekNumber ] ]
                        [ text (config.weekNumberPrefix ++ String.Extra.fromInt weekNumber) ]

                toWeekRow ( weekNumber, week ) =
                    if config.weekNumbers then
                        tr [] (weekNumberCell weekNumber :: List.map toCell week)
                    else
                        tr [] (List.map toCell week)

                body =
                    tbody [ config.class [ Days ] ]
                        (daysAndWeeks.days
                            |> List.Extra.groupsOf 7
                            |> List.Extra.zip daysAndWeeks.weeks
                            |> List.map toWeekRow
                        )
            in
                table [ config.class [ Calendar ] ]
                    [ header
                    , body
                    ]


dayNames : Config a msg -> List (Html msg)
dayNames config =
    let
        days =
            [ th [] [ text config.nameOfDays.sunday ]
            , th [] [ text config.nameOfDays.monday ]
            , th [] [ text config.nameOfDays.tuesday ]
            , th [] [ text config.nameOfDays.wednesday ]
            , th [] [ text config.nameOfDays.thursday ]
            , th [] [ text config.nameOfDays.friday ]
            , th [] [ text config.nameOfDays.saturday ]
            ]

        shiftAmount =
            DateTimePicker.DateUtils.dayToInt Date.Sun config.firstDayOfWeek

        insertWeekNumberColumn list =
            if config.weekNumbers then
                th [] [] :: list
            else
                list
    in
        days
            |> List.Extra.splitAt shiftAmount
            |> (\( head, tail ) -> tail ++ head)
            |> insertWeekNumberColumn


dateClickHandler : Config a msg -> InternalState -> Int -> Date.Month -> DateTimePicker.DateUtils.Day -> msg
dateClickHandler config (InternalState state) year month day =
    let
        selectedDate =
            Just <|
                DateTimePicker.DateUtils.toDate year month day

        updatedState =
            InternalState
                { state
                    | date = selectedDate
                    , forceClose = True
                    , activeTimeIndicator =
                        if state.time.hour == Nothing then
                            Just DateTimePicker.Internal.HourIndicator
                        else if state.time.minute == Nothing then
                            Just DateTimePicker.Internal.MinuteIndicator
                        else if state.time.amPm == Nothing then
                            Just DateTimePicker.Internal.AMPMIndicator
                        else
                            Nothing
                }
    in
        case day.monthType of
            DateTimePicker.DateUtils.Previous ->
                config.onChange (gotoPreviousMonth updatedState) selectedDate

            DateTimePicker.DateUtils.Next ->
                config.onChange (gotoNextMonth updatedState) selectedDate

            DateTimePicker.DateUtils.Current ->
                config.onChange updatedState selectedDate
