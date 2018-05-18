miso-example
============

A miso example

Incremental build
-----------------

First time:

* In tab 1: `nix-shell -A shells.ghc`

* In tab 2: `nix-shell -A shells.ghcjs`

* In tab 1: `cabal new-build all`

* In tab 2: `cabal --project-file=cabal-ghcjs.project --builddir=dist-ghcjs new-build all`

* `ln -s dist-newstyle/build/<path-to-server-binary> miso-example`

* `mkdir -p static`

* `ln -s ../dist-ghcjs/build/<path-to-client-javascript> static/all.js`

Every subseqeuent time (do not close the tabs):

* In tab 1: `cabal new-build all`

* In tab 2: `cabal --project-file=cabal-ghcjs.project --builddir=dist-ghcjs new-build all`

Standard build
--------------

* `nix-build`

* `ln -s result/ghc/server/bin/server miso-example`

* `mkdir -p static`

* `ln -s ../result/ghcjs/client/bin/client.jsexe/all.js static/all.js`

Run
---

* `./miso-example <PORT>`

* Open `localhost:<PORT>` in web browser
