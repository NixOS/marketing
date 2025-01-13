let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
in

pkgs.mkShell {
  packages = with pkgs; [
    ruff
    (python3.withPackages (
      ps: with ps; [
        dateutils
      ]
    ))
  ];
}
