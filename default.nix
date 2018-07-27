(import ./reflex-platform { useTextJSString = false; }).project ({ pkgs, ... }: {
  overrides = self: super: {
    miso = pkgs.haskell.lib.addBuildDepend (self.callCabal2nix "miso" (pkgs.fetchFromGitHub {
      owner = "tysonzero";
      repo = "miso";
      rev = "bce8ffa8e56a99a84ebed360780d9fdc8f4d0822";
      sha256 = "1p17rk5nd1j2p0givqxyd330h4gswkgiqyn6hn7153i4s5m6a4mg";
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
