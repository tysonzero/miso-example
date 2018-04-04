{-# LANGUAGE TypeApplications #-}

module Main (main) where

import Data.Proxy (Proxy(Proxy))
import Miso
    ( App(App), defaultEvents, Effect, events, initialAction, miso
    , model, mountPoint, noEff, pushURI, route, subs, update, uriSub, view, (<#)
    )
import Servant.Utils.Links (URI)

import Common

main :: IO ()
main = miso $ \uri -> do
    let state = routeApp uri
    App { model = state
        , update = handler
        , view = mainView
        , initialAction = Sync
        , events = defaultEvents
        , mountPoint = Nothing
        , subs = [uriSub HandleURI]
        }

handler :: Action -> State -> Effect Action State
handler NoOp m = noEff m
handler (ChangeURI u) m = m <# do
    pushURI u
    pure NoOp
handler (HandleURI u) _ = let state = routeApp u in state <# pure Sync
handler Sync m@(FooPage (Left fooId)) = m <# do
    pure . SetFoo . Foo $ "Foo Number " ++ show fooId
handler AddOne (HomePage fooId) = noEff . HomePage $ fooId + 1
handler SubtractOne (HomePage fooId) = noEff . HomePage $ fooId - 1
handler (SetFoo foo) (FooPage _) = noEff $ FooPage (Right foo)
handler _ m = noEff m

routeApp :: URI -> State
routeApp u = case route (Proxy @Routes) handlers u of
    Left _ -> Error404Page
    Right x -> x
