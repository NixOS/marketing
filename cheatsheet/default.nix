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
in
pkgs.stdenvNoCC.mkDerivation {
  name = "nixos-cheat-sheet";
  phases = [
    "unpackPhase" # just for fetching the src
    "buildPhase"
    "installPhase"
  ];

  src = ./.;

  buildInputs = [
    tex
    pkgs.inkscape # for svg images
    pkgs.python3Packages.pygments # for minted code blocks
  ];

  buildPhase = ''
    DIR=$(mktemp -d)
    env TEXMFHOME="$DIR/.cache" \
    TEXMFVAR="$DIR/.cache/texmf-var" \
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
