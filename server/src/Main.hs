{-# LANGUAGE DataKinds, LambdaCase, OverloadedStrings, TypeApplications, TypeOperators #-}

module Main (main) where

import Data.Proxy (Proxy(Proxy))
import Lucid
    ( ToHtml, body_, charset_, doctypehtml_, head_, meta_, script_, src_, toHtml, toHtmlRaw, title_
    )
import Miso (ToServerRoutes)
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
    serverHandlers = go homeURI :<|> go . fooURI
      where
        go u = pure . HtmlPage . mainView . fst $ routeApp u

type ServerAPI = StaticAPI :<|> ServerRoutes

type StaticAPI = "static" :> Raw

type ServerRoutes = ToServerRoutes Routes HtmlPage Action

newtype HtmlPage a = HtmlPage a

instance ToHtml a => ToHtml (HtmlPage a) where
    toHtmlRaw = toHtml
    toHtml (HtmlPage x) = doctypehtml_ $ do
        head_ $ do
            title_ "Miso Example"
            meta_ [charset_ "utf-8"]
            script_ [src_ "/static/all.js"] ("" :: String)
        body_ $ toHtml x
