(import ./reflex-platform { useTextJSString = false; }).project ({ pkgs, ... }: {
  overrides = self: super: {
    miso = pkgs.haskell.lib.addBuildDepend (self.callCabal2nix "miso" (pkgs.fetchFromGitHub {
      owner = "tysonzero";
      repo = "miso";
      rev = "b36ceabbf3348ac4f4ec38b947f824084836adac";
      sha256 = "1mq3xcwp95pfnz462234nvxwm9g1h7xxrxfwycqgcgs8dxifs2iy";
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
