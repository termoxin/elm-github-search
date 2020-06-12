module Main exposing (..)

import Browser
import Html exposing (Html, a, button, div, h1, img, input, li, ol, p, strong, text, ul)
import Html.Attributes exposing (alt, class, href, placeholder, src, target, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)



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
    , repos : List Repository
    }


type alias Repository =
    { name : String
    , link : String
    , description : String
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
      , repos = []
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = EnteredSearch String
    | GotUser (Result Http.Error User)
    | SearchUser
    | FetchRepos
    | GotRepos (Result Http.Error (List Repository))


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

        FetchRepos ->
            let
                responseDecoder : Decoder Repository
                responseDecoder =
                    Decode.succeed Repository
                        |> required "name" string
                        |> required "html_url" string
                        |> optional "description" string ""

                cmd : Cmd Msg
                cmd =
                    Http.get
                        { url = "https://api.github.com/users/" ++ model.search ++ "/repos"
                        , expect = Http.expectJson GotRepos (list responseDecoder)
                        }
            in
            ( model, cmd )

        GotRepos (Ok repos) ->
            ( { model | repos = repos }, Cmd.none )

        GotRepos (Err error) ->
            Debug.todo "Save error to show it in UI"
                ( model, Cmd.none )



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


viewRepository : Repository -> Html Msg
viewRepository repo =
    li [ class "repository" ] [ a [ href repo.link, target "__blank" ] [ text repo.name ] ]


viewRepositories : User -> List Repository -> Html Msg
viewRepositories user repos =
    if not (String.isEmpty user.name) then
        if List.isEmpty repos then
            h1 [] [ text "The user's repos are not fetched yet" ]

        else
            ol [] (List.map viewRepository repos)

    else
        div [] []


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [] [ text model.search ]
        , div [ class "content-container" ] [ viewUser model.user, viewRepositories model.user model.repos ]
        , input [ type_ "text", class "search-input", placeholder "Type something to search", onInput EnteredSearch ] []
        , div [ class "buttons-container" ]
            [ button [ onClick SearchUser ] [ text "Search" ]
            , if not (String.isEmpty model.user.name) then
                button [ onClick FetchRepos ] [ text "Search repos" ]

              else
                div [] []
            ]
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
