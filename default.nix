(import ./reflex-platform { useTextJSString = false; }).project ({ pkgs, ... }: {
  overrides = self: super: {
    miso = pkgs.haskell.lib.addBuildDepend (self.callCabal2nix "miso" (pkgs.fetchFromGitHub {
      owner = "tysonzero";
      repo = "miso";
      rev = "20578268b7a34fa379f1bab925917c5da06b535e";
      sha256 = "1cw2zldyzp7xpah0xccy2li16k8f3kyddrjc8xmzqc47199dc9g3";
    }) {}) self.ghcjs-base;
  };

  packages = {
    common = ./common;
    server = ./server;
    client = ./client;
  };

  shells = {
    ghc = ["common" "server"];
    ghcjs = ["common" "client"];
  };
})
