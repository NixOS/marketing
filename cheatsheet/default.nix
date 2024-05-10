{ pkgs }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-basic
      environ
      etoolbox
      fancyvrb
      koma-script
      latexmk
      listings
      listingsutf8
      metafont
      hyperref
      minted
      pdfcol
      pgf
      svg
      tcolorbox
      texlive-scripts
      tikzfill
      transparent
      upquote
      xcolor
      ;
  };

  inherit (pkgs) lib;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "nixos-cheat-sheet";
  phases = [
    "unpackPhase" # just for fetching the src
    "buildPhase"
    "installPhase"
  ];

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./main.tex
      ./paper-a4.tex
      ./color-default.tex
      ./nixos.svg
      ./background.svg
    ];
  };

  buildInputs = [
    tex
    pkgs.inkscape # for svg images
    pkgs.python3Packages.pygments # for minted code blocks
  ];

  # HOME needs to be set to keep inkscape/Fontconfig from complaining
  buildPhase = ''
    DIR=$(mktemp -d)
    env TEXMFHOME="$DIR/.cache" \
    TEXMFVAR="$DIR/.cache/texmf-var" \
    HOME="$DIR/home" \
    latexmk \
      -interaction=nonstopmode \
      -pdf -pdflatex \
      -output-directory="." \
      -shell-escape \
      main.tex
  '';

  installPhase = ''
    mkdir $out
    cp main.pdf $out/cheatsheet.pdf
  '';
}
