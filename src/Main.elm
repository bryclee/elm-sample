port module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)


type alias Flags =
    { geolocation : Bool
    , deviceOrientation : Bool
    }


main =
    Html.programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- Init


type alias Position =
    { lat : Float
    , long : Float
    }


type alias Orientation =
    { alpha : Float
    , beta : Float
    , gamma : Float
    }


type alias Model =
    { position : Position
    , orientation : Orientation
    , geolocation : Bool
    , deviceOrientation : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init { geolocation, deviceOrientation } =
    ( Model
        (Position 0 0)
        (Orientation 0 0 0)
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

        UpdateGeolocation { latitude, longitude } ->
            ( { model
                | position =
                    { lat = latitude
                    , long = longitude
                    }
              }
            , Cmd.none
            )

        UpdateDeviceOrientation orientation ->
            ( { model | orientation = orientation }, Cmd.none )



-- Subscribe


type alias LocResult =
    { latitude : Float
    , longitude : Float
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


view : Model -> Html Msg
view model =
    div
        [ class "container" ]
        [ div []
            [ button [ onClick EnableGeolocation ] [ text "Enable geolocation" ]
            , debugInfo
                [ ( "Geolocation supported: ", toString (model.geolocation) )
                , ( "Device Orientation supported: ", toString (model.deviceOrientation) )
                , ( "Latitude: ", toString (model.position.lat) )
                , ( "Longitude: ", toString (model.position.long) )
                , ( "Alpha: ", toString (round model.orientation.alpha) )
                , ( "Beta: ", toString (round model.orientation.beta) )
                , ( "Gamma: ", toString (round model.orientation.gamma) )
                ]
            ]
        ]
