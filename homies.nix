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
      neovim

      pkgs.curl
      pkgs.direnv
      pkgs.gnupg
      pkgs.nixpkgs-fmt
      pkgs.niv
      pkgs.fzf
      pkgs.htop
      pkgs.jq
      pkgs.less
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.tree
    ];
}
