{ pkgs, nixpkgs-src, inputs, git-src, niv-src }:
# The main homies file, where homies are defined. See the README.md for
# instructions.
let

  nix = pkgs.callPackage ./nix { };

  neovim = pkgs.callPackage ./neovim { inherit inputs; };

  kitty = pkgs.callPackage ./kitty { inherit inputs; };

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = pkgs.callPackage ./bashrc { inherit nixpkgs-src; };

  # Git with config baked in
  git = pkgs.callPackage ./git (
    {
      inherit git-src;
    });

  niv =
    let
      # Workaround for https://github.com/NixOS/nixpkgs/issues/140774
      fixCyclicReference = drv:
        pkgs.haskell.lib.overrideCabal drv (_: {
          enableSeparateBinOutput = false;
        });
    in
    fixCyclicReference pkgs.haskellPackages.niv;
in

# The "homies", which is a buildEnv where bin/ contains all the executables.
  # The manpages are in share/man, which are auto-discovered by man (because
  # it's close to bin/ which is on the PATH).
pkgs.buildEnv {
  name = "homies";
  paths =
    [
      bashrc
      git
      kitty
      nix
      niv
      neovim

      pkgs.curl
      pkgs.direnv
      pkgs.gnupg
      pkgs.nixpkgs-fmt
      pkgs.fzf
      pkgs.htop
      pkgs.jq
      pkgs.less
      pkgs.haskellPackages.wai-app-static
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.tree
    ];
}
