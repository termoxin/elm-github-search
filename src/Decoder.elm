module Decoder exposing (Repository, User, repositoryDecoder, userDecoder)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (optional, required)


type alias User =
    { username : String
    , name : String
    , photoUrl : String
    , link : String
    }


type alias Repository =
    { name : String
    , link : String
    , description : String
    }


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "login" string
        |> required "name" string
        |> required "avatar_url" string
        |> required "url" string


repositoryDecoder : Decoder Repository
repositoryDecoder =
    Decode.succeed Repository
        |> required "name" string
        |> required "html_url" string
        |> optional "description" string ""
