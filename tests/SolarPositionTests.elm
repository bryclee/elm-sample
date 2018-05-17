module SolarPositionTests exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import SolarPosition exposing (Date, getDateNumber, calc)


suite : Test
suite =
    describe "SolarPosition"
        [ describe "getDateNumber"
            [ test "Jan 1 1900" <|
                \_ ->
                    Expect.equal 1 (getDateNumber (Date 1900 1 1))
            , test "Jan 1, 2008" <|
                \_ ->
                    Expect.equal 39448 (getDateNumber (Date 2008 1 1))
            , test "Dec 31, 1900 (Leap year)" <|
                \_ ->
                    Expect.equal 366 (getDateNumber (Date 1900 12 31))
            , test "Dec 31, 1901 (non-leap year)" <|
                \_ ->
                    Expect.equal 731 (getDateNumber (Date 1901 12 31))
            ]
        ]
