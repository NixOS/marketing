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

  pygments = pkgs.python3Packages.pygments.overridePythonAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      # removed bold and italics formatting for comments and strings
      ./unformatted-comments-strings.patch
    ];
  });

  inherit (pkgs) lib;

  combinations = lib.cartesianProduct {
    paper = [
      "a4"
      "letter"
    ];
    color = [
      "default"
      "bw"
    ];
  };
in
lib.listToAttrs (
  builtins.map (elem: {
    name = "cheat-sheet-${elem.paper}-${elem.color}";

    value = pkgs.stdenvNoCC.mkDerivation {
      name = "nixos-cheat-sheet";

      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./main.tex
          ./paper-${elem.paper}.tex
          ./color-${elem.color}.tex
          ./nixos.svg
          ./background.svg
        ];
      };

      buildInputs = [
        tex
        pkgs.inkscape # for svg images
        pygments # for minted code blocks
      ];

      # HOME needs to be set to keep inkscape/Fontconfig from complaining
      buildPhase = ''
        mv paper-${elem.paper}.tex paper.tex
        mv color-${elem.color}.tex color.tex

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
        cp main.pdf $out/cheat-sheet-${elem.paper}-${elem.color}.pdf
      '';
    };
  }) combinations
)
