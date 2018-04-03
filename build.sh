nix-shell -A shells.ghc --run "cabal new-build all"
nix-shell -A shells.ghcjs --run "cabal --project-file=cabal-ghcjs.project --builddir=dist-ghcjs new-build all"
