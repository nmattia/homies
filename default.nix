let
  pkgs = import <nixpkgs> {};

  homies = with pkgs;
    [
      # vim
      curl
      git
      htop
      nix
      tmux
      tree
      xclip
    ];

  homiesPaths = map (homie: (pkgs.lib.getOutput "bin" homie) + "/bin/*") homies;

in pkgs.stdenv.mkDerivation
  { name = "home-sweet-home";
    src = null;
    builder = pkgs.writeScript "homies"
    ''
      source $stdenv/setup
      mkdir $out
      pushd $out
      for exec in ${pkgs.lib.strings.concatStringsSep " " homiesPaths}; do
          ln -s $exec .
      done
      popd
    '';
  }
