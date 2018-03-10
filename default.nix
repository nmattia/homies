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

in homies
