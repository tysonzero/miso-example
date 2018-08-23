(import ./reflex-platform { useTextJSString = false; }).project ({ pkgs, ... }: {
  overrides = self: super: {
    miso = pkgs.haskell.lib.addBuildDepends (self.callCabal2nix "miso" (pkgs.fetchFromGitHub {
      owner = "dmjio";
      repo = "miso";
      rev = "580d678539c62009a21723d2def3b11a42d99493";
      sha256 = "1q64w64fa2m03x8vj26rlkl69bpfk5sx9vw6bayakxcc9fngj8jc";
    }) {}) [self.QuickCheck self.ghcjs-base self.quickcheck-instances];
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
