{ pkgs, system ? builtins.currentSystem, nixpkgs, vimPlugins, git-src, niv-src }:
# The main homies file, where homies are defined. See the README.md for
# instructions.
let
  # The "homies", which is a buildEnv where bin/ contains all the executables.
  # The manpages are in share/man, which are auto-discovered by man (because
  # it's close to bin/ which is on the PATH).
  homies = pkgs.buildEnv {
    name = "homies";
    paths =
      [
        bashrc
        git
        tmux
        nix
        neovim

        pkgs.curl
        pkgs.direnv
        pkgs.nixpkgs-fmt
        pkgs.niv
        pkgs.fzf
        pkgs.htop
        pkgs.jq
        pkgs.less
        pkgs.python
        pkgs.haskellPackages.wai-app-static
      ];
  };

  nix = pkgs.callPackage ./nix {};

  neovim = pkgs.callPackage ./neovim { inherit vimPlugins; };

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = pkgs.callPackage ./bashrc { inherit nixpkgs; };

  # Git with config baked in
  git = pkgs.callPackage ./git (
    {
      inherit git-src;
    });

  # Tmux with a custom tmux.conf baked in
  tmux = import ./tmux (with pkgs;
    {
      inherit
        makeWrapper
        symlinkJoin
        writeText
        ;
      tmux = pkgs.tmux;
    });

  # Vim with a custom vimrc and set of packages
  vim = pkgs.callPackage ./vim
    {
      inherit
        git
        tmux;
    };
in
{ inherit homies bashrc; }
