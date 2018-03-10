let
  pkgs = import <nixpkgs> {};

  vim = import ./vim (with pkgs;
    {inherit
        symlinkJoin
        makeWrapper
        vim_configurable
        vimUtils
        vimPlugins
        haskellPackages;
    });
  homies = with pkgs;
    [
      vim
      pkgs.curl
      pkgs.git
      pkgs.htop
      pkgs.nix
      pkgs.tmux
      pkgs.tree
      pkgs.xclip
    ];

  homiesPaths =
    map (homie: (pkgs.lib.getOutput "bin" homie) + "/bin/*") homies;

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
