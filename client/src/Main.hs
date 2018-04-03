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
handler AddOne (HomePage fooId) = noEff . HomePage $ fooId + 1
handler SubtractOne (HomePage fooId) = noEff . HomePage $ fooId - 1
handler (GetFoo fooId) m = m <# do
    pure . SetFoo . Foo $ "Foo Number " ++ show fooId
handler (SetFoo foo) (FooPage _) = noEff $ FooPage (Just foo)
handler _ m = noEff m
