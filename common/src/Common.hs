{-# LANGUAGE DataKinds, OverloadedStrings, TypeApplications, TypeOperators #-}

module Common
    ( Action(AddOne, ChangeURI, HandleURI, NoOp, SetFoo, SubtractOne, Sync)
    , Foo(Foo), Routes, State(Error404Page, HomePage, FooPage), fooURI, handlers, homeURI, mainView
    ) where

import Data.Proxy (Proxy(Proxy))
import Miso (View, button_, div_, onClick, text)
import Miso.String (toMisoString)
import Miso.TypeLevel (MapHandlers)
import Servant.API (Capture, (:<|>)((:<|>)), (:>))
import Servant.Utils.Links (URI, linkURI, safeLink)

-- Routing

handlers :: MapHandlers State Routes
handlers = HomePage 0 :<|> FooPage . Left

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

fooView :: Either Int Foo -> View Action
fooView (Left _) = div_ [] []
fooView (Right (Foo fooStr)) = div_ []
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

data State = HomePage Int | FooPage (Either Int Foo) | Error404Page
    deriving Eq

data Action
    = NoOp
    | ChangeURI URI
    | HandleURI URI
    | Sync
    | AddOne
    | SubtractOne
    | SetFoo Foo

newtype Foo = Foo String
    deriving Eq
