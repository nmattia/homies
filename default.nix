# The main homies file, where homies are defined. See the README.md for
# instructions.
let
  pkgs = import ./nix { };

  # The list of packages to be installed
  homies = with pkgs;
    [
      # Customized packages
      bashrc
      git
      nixpkgs-fmt
      tmux
      neovim
      vim

      pkgs.curl
      pkgs.inconsolata-nerdfont
      pkgs.direnv
      pkgs.fzf
      pkgs.haskellPackages.wai-app-static
      pkgs.htop
      pkgs.jq
      pkgs.less
      pkgs.niv
      pkgs.nix
      pkgs.python
    ];

  neovim = pkgs.callPackage ./neovim {};

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = pkgs.callPackage ./bashrc { };

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
in
if
  builtins.getEnv "IN_NIX_SHELL" == "impure"
then
  pkgs.mkShell
  {
    nativeBuildInputs = [ homies ];
    shellHook = "$(bashrc)";
  }
else homies
