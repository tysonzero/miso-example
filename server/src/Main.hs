{-# LANGUAGE DataKinds, LambdaCase, OverloadedStrings, TypeApplications, TypeOperators #-}

module Main (main) where

import Data.Proxy (Proxy(Proxy))
import Lucid (Html, body_, charset_, doctypehtml_, head_, meta_, script_, src_, toHtml, title_)
import Miso (View)
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.RequestLogger (logStdout)
import Servant (Application, Raw, serve, serveDirectoryWebApp, (:<|>)((:<|>)), (:>))
import System.Environment (getArgs)
import Text.Read (readMaybe)

import Common

main :: IO ()
main = fmap readMaybe <$> getArgs >>= \case
    [] -> error "No port number specified"
    Nothing : _ -> error "Invalid port number specified"
    Just port : _ -> run port $ logStdout app

app :: Application
app = serve (Proxy @ServerAPI) (staticHandler :<|> serverHandlers)
  where
    staticHandler = serveDirectoryWebApp "static"
    serverHandlers = routes (pure . page . mainView . fst)

type ServerAPI = StaticAPI :<|> Routes

type StaticAPI = "static" :> Raw

page :: View a -> Html ()
page x = doctypehtml_ $ do
    head_ $ do
        title_ "Miso Example"
        meta_ [charset_ "utf-8"]
        script_ [src_ "/static/all.js"] ("" :: String)
    body_ $ toHtml x
