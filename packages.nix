{ system ? builtins.currentSystem, vimPlugins, git-src, niv-src }:
# The main homies file, where homies are defined. See the README.md for
# instructions.
let
  pkgs = import ./nix { inherit system niv-src; };

  neovim = pkgs.callPackage ./neovim { inherit vimPlugins; };

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = pkgs.callPackage ./bashrc { inherit homies; };

  # Git with config baked in
  git = import ./git (
    {
      inherit (pkgs) sources runCommand makeWrapper symlinkJoin writeTextFile git;
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

    homies = pkgs.hiPrio (pkgs.buildEnv {
      name = "homies"; paths = builtins.attrValues homiesList;
    });

  homiesList =
    # All packages to be installed
    { inherit bashrc git tmux neovim vim; } //
    { inherit (pkgs) curl direnv nixpkgs-fmt niv fzf htop jq less nix python; } //
    { warp = pkgs.haskellPackages.wai-app-static; };
in
  { inherit homies bashrc; }
