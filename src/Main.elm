port module Main exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Html.Styled.Attributes exposing (css, class)


type alias Flags =
    { geolocation : Bool
    , deviceOrientation : Bool
    }


main =
    Html.programWithFlags
        { init = init
        , view = view >> toUnstyled
        , subscriptions = subscriptions
        , update = update
        }



-- Init


type alias Position =
    { lat : Float
    , long : Float
    , heading : Maybe Float
    }


type alias Orientation =
    { heading : Float
    , absolute : Bool
    , alpha : Float
    }


type alias Model =
    { position : Position
    , orientation : Orientation
    , reference : Float
    , geolocation : Bool
    , deviceOrientation : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init { geolocation, deviceOrientation } =
    ( Model
        (Position 0 0 Nothing)
        (Orientation 0 False 0)
        0
        geolocation
        deviceOrientation
    , Cmd.none
    )



-- Update


type Msg
    = EnableGeolocation
    | UpdateGeolocation LocResult
    | UpdateDeviceOrientation Orientation


port requestGeolocation : () -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnableGeolocation ->
            ( model, requestGeolocation () )

        UpdateGeolocation { latitude, longitude, heading } ->
            let
                newRef =
                    case heading of
                        Nothing ->
                            model.reference

                        Just n ->
                            model.orientation.alpha - n

                newPosition =
                    Position latitude longitude heading
            in
                ( { model
                    | position = newPosition
                    , reference = newRef
                  }
                , Cmd.none
                )

        UpdateDeviceOrientation newData ->
            let
                newHeading =
                    if newData.absolute then
                        newData.heading
                    else
                        newData.alpha - model.reference

                newOrientation =
                    { newData
                        | heading = newHeading
                    }
            in
                ( { model
                    | orientation = newOrientation
                  }
                , Cmd.none
                )



-- Subscribe


type alias LocResult =
    { latitude : Float
    , longitude : Float
    , heading : Maybe Float
    }


port receiveGeolocation : (LocResult -> msg) -> Sub msg


port receiveDeviceOrientation : (Orientation -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveGeolocation UpdateGeolocation
        , receiveDeviceOrientation UpdateDeviceOrientation
        ]



-- View


debugInfo : List ( String, String ) -> Html Msg
debugInfo infos =
    div []
        (List.map
            (\( label, data ) -> div [] [ text (label ++ data) ])
            infos
        )


theme =
    { primary = (hex "42f4c2")
    , secondary = (hex "c8d8c3")
    }

fontBase : Style
fontBase =
    Css.batch
        [ fontFamilies ["Open Sans", "Arial", "sans-serif"]
        ]

compass : Orientation -> Html Msg
compass orientation =
    div
        [ css
            [ width (px 200)
            , height (px 200)
            , borderRadius (pct 50)
            , border3 (px 10) solid theme.primary
            , transform (rotate (deg orientation.heading))
            -- margin to vertical spacing?
            , margin2 zero auto
            ]
        ]
        [ div
            [ css
                [ width (px 30)
                , height (px 30)
                , backgroundColor theme.primary
                , margin2 zero auto
                ]
            ]
            []
        ]


view : Model -> Html Msg
view model =
    div
        [ css
            [ fontBase
            , maxWidth (px 600)
            , margin2 zero auto
            , textAlign center
            ]
        ]
        [ div []
            [ button [ onClick EnableGeolocation ] [ text "Watch geolocation" ]
            , debugInfo
                [ ( "Geolocation supported: ", toString (model.geolocation) )
                , ( "Device Orientation supported: ", toString (model.deviceOrientation) )
                , ( "Latitude: ", toString (model.position.lat) )
                , ( "Longitude: ", toString (model.position.long) )
                , ( "Heading: ", toString (Basics.round model.orientation.heading) )
                , ( "Absolute: ", toString (model.orientation.absolute) )
                , ( "Reference: ", toString (Basics.round model.reference) )
                , ( "Alpha: ", toString (Basics.round model.orientation.alpha) )
                ]
            , compass model.orientation
            ]
        ]
