port module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)


type alias Flags =
    { geolocation : Bool
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


type alias Model =
    { position : Position
    , geolocation : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init { geolocation } =
    ( Model (Position 0 0) geolocation, Cmd.none )



-- Update


type Msg
    = EnableGeolocation
    | UpdateGeolocation LocResult


port requestGeolocation : () -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnableGeolocation ->
            ( model, requestGeolocation () )

        UpdateGeolocation res ->
            ( { model
                | position =
                    { lat = res.coords.latitude
                    , long = res.coords.longitude
                    }
              }
            , Cmd.none
            )



-- Subscribe


type alias LocResult =
    { coords :
        { latitude : Float
        , longitude : Float
        , heading : Int
        }
    , timestamp : Int
    }


port receiveGeolocation : (LocResult -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveGeolocation UpdateGeolocation



-- View


view : Model -> Html Msg
view model =
    div
        [ class "container" ]
        [ div []
            [ div []
                [ text
                    ("Geolocation supported: " ++ (toString model.geolocation))
                ]
            , button [ onClick EnableGeolocation ] [ text "Hello World...." ]
            , div []
                [ text
                    ("latitude: " ++ toString model.position.lat)
                ]
            , div []
                [ text
                    ("longitude: " ++ toString model.position.long)
                ]
            ]
        ]
