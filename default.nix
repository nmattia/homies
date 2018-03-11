let
  pkgs = import (import ./nixpkgs) {};

  # bashrc should be evaluated from your actual .bashrc:
  #   if [ -x "$(command -v bashrc)" ]; then $(bashrc); fi
  bashrc = import ./bashrc (with pkgs;
    { inherit
        writeScriptBin
        ;
    });

  # Git with config baked in
  git = import ./git (with pkgs;
    { inherit
        makeWrapper
        symlinkJoin
        ;
      git = pkgs.git;
    });

  # Tmux with tmux.conf baked in
  tmux = import ./tmux (with pkgs;
    { inherit
        makeWrapper
        symlinkJoin
        writeText
        ;
      tmux = pkgs.tmux;
    });


  # Vim with a custom set of packages
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
      # Customized packages
      bashrc
      git
      tmux
      vim

      pkgs.curl
      pkgs.htop
      pkgs.nix
      pkgs.pass
      pkgs.tree
      pkgs.xclip
    ];

in
  if pkgs.lib.inNixShell
  then pkgs.mkShell
    { buildInputs = homies;
      shellHook = ''
        $(bashrc)
        '';
    }
  else homies
