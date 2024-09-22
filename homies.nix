{ pkgs, nixpkgs-src, inputs, niv-src }:
# The main homies file, where homies are defined. See the README.md for
# instructions.
let

  nix = pkgs.callPackage ./nix { };

  neovim = pkgs.callPackage ./neovim { inherit inputs; };

  kitty = pkgs.callPackage ./kitty { inherit inputs; };

  # A custom '.zshrc' (see zshrc/default.nix for details)
  zshrc = pkgs.callPackage ./zshrc { inherit nixpkgs-src; };

  # Git with config baked in
  git = pkgs.callPackage ./git {};
in

# The "homies", which is a buildEnv where bin/ contains all the executables.
  # The manpages are in share/man, which are auto-discovered by man (because
  # it's close to bin/ which is on the PATH).
pkgs.buildEnv {
  name = "homies";
  paths =
    [
      zshrc
      git
      kitty.wrapper
      kitty.bundle
      nix
      neovim

      pkgs.curl
      pkgs.direnv
      pkgs.git-lfs
      pkgs.gnupg
      pkgs.nixpkgs-fmt
      pkgs.niv
      pkgs.fzf
      pkgs.htop
      pkgs.jq
      pkgs.less
      pkgs.scc
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.tree
    ];
}
