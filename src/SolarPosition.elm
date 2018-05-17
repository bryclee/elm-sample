module SolarPosition exposing (calc, getDateNumber, Date)


type alias Date =
    { year : Int
    , month : Int
    , day : Int
    }


type alias Position =
    { longitude : Float
    , latitude : Float
    }


type alias SolarPosition =
    { azimuth : Float
    , elevation : Float
    }


isLeapYear : Int -> Bool
isLeapYear year =
    (year % 4) == 0


getDaysPerMonthMapper : Int -> Bool -> Int
getDaysPerMonthMapper month isLeap =
    case month of
        1 -> 31
        2 -> if isLeap then 29 else 28
        3 -> 31
        4 -> 30
        5 -> 31
        6 -> 30
        7 -> 31
        8 -> 31
        9 -> 30
        10 -> 31
        11 -> 30
        12 -> 31
        _ -> 0


getDaysPerMonth : Int -> Bool -> Int
getDaysPerMonth month isLeap =
    if month == 0 then
        0
    else
        (getDaysPerMonthMapper month isLeap) + (getDaysPerMonth (month - 1) isLeap)



-- Returns days since Jan 1, 1900


getDateNumber : Date -> Int
getDateNumber { year, month, day } =
    let
        diffYear =
            year - 1900
    in
        (diffYear * 365 + (ceiling ((toFloat diffYear) / 4)))
            + (getDaysPerMonth (month - 1) (isLeapYear year))
            + day


getJulianDay : Date -> Float
getJulianDay date =
    1



{--
getJDE : Float -> Float
getJDE jd =
    jd +
--}


calc : Position -> SolarPosition
calc position =
    SolarPosition 0 0
