let
  pkgs = import <nixpkgs> {};

  # bashrc should be evaluated from your actual .bashrc:
  #   if [ -x "$(command -v bashrc)" ]; then $(bashrc); fi
  bashrc = import ./bashrc (with pkgs;
    { inherit
        writeScriptBin
        ;
    });

  tmux = import ./tmux (with pkgs;
    { inherit
        makeWrapper
        symlinkJoin
        writeText
        ;
      tmux = pkgs.tmux;
    });

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
      tmux
      vim
      bashrc

      pkgs.curl
      pkgs.git
      pkgs.htop
      pkgs.nix
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
