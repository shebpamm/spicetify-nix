{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "spicetify-1.1.0";

  src = pkgs.fetchurl {
    name = "spicetify-1.1.0-linux-amd64.tar.gz";
    url = "https://github.com/khanhas/spicetify-cli/releases/download/v2.8.3/spicetify-2.8.3-linux-amd64.tar.gz":
    sha256 = "sha256:63b565b5b8826cb5069306c48f285042dd4b03e3dc7a4b23325f50e38d2d658f";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
