{-# LANGUAGE DataKinds, OverloadedStrings, TypeApplications, TypeOperators #-}

module Common
    ( Action(AddOne, ChangeURI, GetFoo, HandleURI, NoOp, SetFoo, SubtractOne)
    , Foo(Foo), Routes, State(HomePage, FooPage), fooURI, homeURI, mainView, routeApp
    ) where

import Data.Proxy (Proxy(Proxy))
import Miso (View, button_, div_, onClick, route, text)
import Miso.String (toMisoString)
import Servant.API (Capture, (:<|>)((:<|>)), (:>))
import Servant.Utils.Links (URI, linkURI, safeLink)

-- Routing

routeApp :: URI -> (State, Action)
routeApp u = case route (Proxy @Routes) viewTree u of
    Left _ -> (Error404Page, NoOp)
    Right x -> x
  where
    viewTree = (HomePage 0, NoOp) :<|> (\fooId -> (FooPage Nothing, GetFoo fooId))

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

type HomeRoute = View Action
type FooRoute = "foo" :> Capture "id" Int :> View Action

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
