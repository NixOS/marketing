{
  description = "NixOS Marketing Team";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        cheatsheets = builtins.removeAttrs (pkgs.callPackage ./cheatsheet { }) [
          "override"
          "overrideDerivation"
        ];
      in
      {
        packages = { } // cheatsheets;
      }
    );
}
