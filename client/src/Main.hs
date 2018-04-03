module Main (main) where

import Miso
    ( App(App), defaultEvents, Effect, events, initialAction, miso
    , model, mountPoint, noEff, pushURI, subs, update, uriSub, view, (<#)
    )

import Common

main :: IO ()
main = miso $ \uri -> do
    let (state, action) = routeApp uri
    App { model = state
        , update = handler
        , view = mainView
        , initialAction = action
        , events = defaultEvents
        , mountPoint = Nothing
        , subs = [uriSub HandleURI]
        }

handler :: Action -> State -> Effect Action State
handler NoOp m = noEff m
handler (ChangeURI u) m = m <# do
    pushURI u
    pure NoOp
handler (HandleURI u) _ = let (state, action) = routeApp u in state <# pure action
handler (GetFoo fooId) m = m <# do
    pure . SetFoo . Foo $ "Foo Number " ++ show fooId
handler (SetFoo foo) _ = noEff $ FooPage (Just foo)
