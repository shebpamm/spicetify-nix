{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "spicetify-1.1.0";

  src = pkgs.fetchurl {
    name = "spicetify-2.8.3-linux-amd64.tar.gz";
    url = "https://github.com/khanhas/spicetify-cli/releases/download/v2.8.3/spicetify-2.8.3-linux-amd64.tar.gz";
    sha256 = "sha256:1yv1G7ppsU7v9PB1jskeOJ54VC1LtVmtspotULdUf/4=";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
