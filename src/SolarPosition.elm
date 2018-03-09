module SolarPosition exposing (calc)


type alias Date =
    { year : Int
    , month : Int
    , day : Float
    }


type alias Position =
    { longitude : Float
    , latitude : Float
    }


type alias SolarPosition =
    { azimuth : Float
    , elevation : Float
    }


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
