{-# LANGUAGE DataKinds, OverloadedStrings, TypeApplications, TypeOperators #-}

module Common
    ( Action(ChangeURI, GetFoo, HandleURI, NoOp, SetFoo), Foo(Foo), Routes, State(FooPage)
    , fooURI, homeURI, mainView, routeApp
    ) where

import Data.Proxy (Proxy(Proxy))
import Miso (View, div_, route, text)
import Servant.API (Capture, (:<|>)((:<|>)), (:>))
import Servant.Utils.Links (URI, linkURI, safeLink)

-- Routing

routeApp :: URI -> (State, Action)
routeApp u = case route (Proxy @Routes) viewTree u of
    Left _ -> (Error404Page, NoOp)
    Right x -> x
  where
    viewTree = (HomePage, NoOp) :<|> (\fooId -> (FooPage Nothing, GetFoo fooId))

-- Views

mainView :: State -> View a
mainView HomePage = homeView
mainView (FooPage mfoo) = fooView mfoo
mainView Error404Page = error404View

homeView :: View a
homeView = div_ [] []

fooView :: Maybe Foo -> View a
fooView _ = div_ [] []

error404View :: View a
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

data State = HomePage | FooPage (Maybe Foo) | Error404Page
    deriving Eq

data Action
    = NoOp
    | ChangeURI URI
    | HandleURI URI
    | GetFoo Int
    | SetFoo Foo

newtype Foo = Foo String
    deriving Eq
