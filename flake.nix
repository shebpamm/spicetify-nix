{
  description = "Spotify patched with spicetify";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/master";
      flake-utils.url = "github:numtide/flake-utils";
      spicetify-themes = { url = "github:morpheusthewhite/spicetify-themes"; flake = false; };
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, spicetify-themes }:
  {
    overlay = final: prev: {
      inherit (self.packages.${final.system})

      spotify-spiced;
    };
  }
  
  // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      packages = {
        spotify-spiced = import ./package.nix { inherit pkgs; themes = inputs.spicetify-themes; };
      };
    }
  );
}

