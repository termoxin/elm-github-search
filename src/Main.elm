module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, img, input, text)
import Html.Attributes exposing (class, placeholder, src, type_)
import Html.Events exposing (onInput)



---- MODEL ----


type alias Model =
    { search : String }


init : ( Model, Cmd Msg )
init =
    ( { search = "" }, Cmd.none )



---- UPDATE ----


type Msg
    = EnteredSearch String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnteredSearch search ->
            ( { model | search = String.reverse search }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [] [ text model.search ]
        , input [ type_ "text", class "search-input", placeholder "Type something to search", onInput EnteredSearch ] []
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
