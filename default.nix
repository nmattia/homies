let
  pkgs = import <nixpkgs> {};

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

      pkgs.curl
      pkgs.git
      pkgs.htop
      pkgs.nix
      pkgs.tree
      pkgs.xclip
    ];

in homies
