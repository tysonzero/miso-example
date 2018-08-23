{-# LANGUAGE DataKinds, OverloadedStrings, TypeApplications, TypeOperators #-}

module Common
    ( Action(AddOne, ChangeURI, GetFoo, HandleURI, NoOp, SetFoo, SubtractOne)
    , Foo(Foo), Routes, State(Error404Page, HomePage, FooPage), fooURI, homeURI, mainView, routes
    ) where

import Data.Proxy (Proxy(Proxy))
import Lucid (Html)
import Miso (RouteT, View, button_, div_, input_, label_, onChecked, onClick, text, type_)
import Miso.String (toMisoString)
import Servant.API (Capture, Get, (:<|>)((:<|>)), (:>))
import Servant.HTML.Lucid (HTML)
import Servant.Utils.Links (URI, linkURI, safeLink)

import Debug.Trace

-- Routing

routes :: ((State, Action) -> a) -> RouteT Routes a
routes f = f (HomePage 0, NoOp) :<|> (\fooId -> f (FooPage Nothing, GetFoo fooId))

-- Views

mainView :: State -> View Action
mainView (HomePage fooId) = homeView fooId
mainView (FooPage mfoo) = fooView mfoo
mainView Error404Page = error404View

homeView :: Int -> View Action
homeView fooId = div_ []
    [ button_ [ onClick SubtractOne ] [ text "-" ]
    , text . toMisoString $ show fooId
    , button_ [ onClick AddOne ] [ text "+" ]
    , button_ [ onClick . ChangeURI $ fooURI fooId ] [ text "go" ]
    , label_ []
        [ input_
            [ type_ "checkbox"
            , onChecked $ \x -> x `traceShow` AddOne
            ]
        ]
    ]

fooView :: Maybe Foo -> View Action
fooView Nothing = div_ [] []
fooView (Just (Foo fooStr)) = div_ []
    [ button_ [ onClick $ ChangeURI homeURI ] [ text "back" ]
    , text $ toMisoString fooStr
    ]

error404View :: View Action
error404View = text "404 not found"

-- Routes / URIs

type Routes = HomeRoute
         :<|> FooRoute

type HomeRoute = Endpoint
type FooRoute = "foo" :> Capture "id" Int :> Endpoint

type Endpoint = Get '[HTML] (Html ())

homeURI :: URI
homeURI = linkURI $ safeLink (Proxy @Routes) (Proxy @HomeRoute)

fooURI :: Int -> URI
fooURI = linkURI . safeLink (Proxy @Routes) (Proxy @FooRoute)

-- State / Action

data State = HomePage Int | FooPage (Maybe Foo) | Error404Page
    deriving Eq

data Action
    = NoOp
    | ChangeURI URI
    | HandleURI URI
    | AddOne
    | SubtractOne
    | GetFoo Int
    | SetFoo Foo

newtype Foo = Foo String
    deriving Eq
