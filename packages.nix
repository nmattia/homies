{ system ? builtins.currentSystem, vimPlugins }:
# The main homies file, where homies are defined. See the README.md for
# instructions.
let
  pkgs = import ./nix { inherit system; };

  neovim = pkgs.callPackage ./neovim { inherit vimPlugins; };

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = pkgs.callPackage ./bashrc { inherit homies; };

  # Git with config baked in
  git = import ./git (
    {
      inherit (pkgs) sources runCommand makeWrapper symlinkJoin writeTextFile;
      git = pkgs.git;
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

  naersk = pkgs.callPackage pkgs.sources.naersk { };

  nixpkgs-fmt = naersk.buildPackage pkgs.sources.nixpkgs-fmt;

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
    { inherit bashrc git nixpkgs-fmt tmux neovim vim; } //
    { inherit (pkgs) curl direnv fzf htop jq less niv nix python; } //
    { warp = pkgs.haskellPackages.wai-app-static; };
in
  { inherit homies bashrc; }
