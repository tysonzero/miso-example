miso-example
============

A miso example

Incremental build
-----------------

* `./build.sh`.

* `ln -s dist-newstyle/build/<path-to-server-binary> miso-example`

* `mkdir -p static`

* `ln -s dist-ghcjs/build/<path-to-client-javascript> static/all.js`

Standard build
--------------

* `nix-build`

* `ln -s result/ghc/server/bin/server miso-example`

* `mkdir -p static`

* `ln -s result/ghcjs/client/bin/client.jsexe/all.js static/all.js`

Run
---

* `./miso-example <PORT>`

* Open `localhost:<PORT>` in web browser
