module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, img, input, p, text)
import Html.Attributes exposing (alt, class, placeholder, src, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)



---- MODEL ----


type alias User =
    { username : String
    , name : String
    , photoUrl : String
    , link : String
    }


type alias Model =
    { error : String
    , search : String
    , user : User
    }


init : ( Model, Cmd Msg )
init =
    ( { error = ""
      , search = ""
      , user =
            { username = ""
            , name = ""
            , photoUrl = ""
            , link = ""
            }
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = EnteredSearch String
    | GotUser (Result Http.Error User)
    | SearchUser


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnteredSearch search ->
            ( { model | search = search }, Cmd.none )

        GotUser (Ok user) ->
            ( { model | user = user }, Cmd.none )

        GotUser (Err error) ->
            Debug.todo "Save error to show it in UI"
                ( model, Cmd.none )

        SearchUser ->
            let
                responseDecoder : Decoder User
                responseDecoder =
                    Decode.succeed User
                        |> required "login" string
                        |> required "name" string
                        |> required "avatar_url" string
                        |> required "url" string

                cmd : Cmd Msg
                cmd =
                    Http.get
                        { url = "https://api.github.com/users/" ++ model.search
                        , expect = Http.expectJson GotUser responseDecoder
                        }
            in
            ( model, cmd )



---- VIEW ----


viewUser : User -> Html Msg
viewUser user =
    div [ class "user-container" ]
        [ img [ src user.photoUrl, alt user.username ] []
        , p [ class "user-name" ]
            [ text
                (if user.name /= "" then
                    "Name: " ++ user.name

                 else
                    ""
                )
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [] [ text model.search ]
        , viewUser model.user
        , input [ type_ "text", class "search-input", placeholder "Type something to search", onInput EnteredSearch ] []
        , button [ class "search-button", onClick SearchUser ] [ text "Search" ]
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
