# The main homies file, where homies are defined. See the README.md for
# instructions.
with { pkgs = import ./nix {}; };
let

  # The list of packages to be installed
  homies = with pkgs;
    [
      # Customized packages
      bashrc
      git
      nixpkgs-fmt
      python
      tmux
      vim

      pkgs.curl
      pkgs.direnv
      pkgs.fzf
      pkgs.gnupg
      pkgs.haskellPackages.wai-app-static
      pkgs.htop
      pkgs.httpie
      pkgs.jq
      pkgs.less
      pkgs.moreutils
      pkgs.niv
      pkgs.nix
      pkgs.nix-diff
      pkgs.pass
      pkgs.shellcheck
      pkgs.tree
      pkgs.xclip
    ];

  ## Some customizations
  python = pkgs.python.withPackages (ps: [ ps.grip ]);

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = pkgs.callPackage ./bashrc {};

  # Git with config baked in
  git = import ./git (
    { inherit (pkgs) makeWrapper symlinkJoin writeTextFile;
      git = pkgs.git;
    });

  # Tmux with a custom tmux.conf baked in
  tmux = import ./tmux (with pkgs;
    { inherit
        makeWrapper
        symlinkJoin
        writeText
        ;
      tmux = pkgs.tmux;
    });

  naersk = pkgs.callPackage pkgs.sources.naersk {};

  rusty-tags = naersk.buildPackage pkgs.sources.rusty-tags;
  nixpkgs-fmt = naersk.buildPackage pkgs.sources.nixpkgs-fmt;

  # Vim with a custom vimrc and set of packages
  vim = pkgs.callPackage ./vim
    { inherit
        git
        tmux
        rusty-tags;
    };

in
  if pkgs.lib.inNixShell
  then pkgs.mkShell
    { buildInputs = homies;
      shellHook = ''
        $(bashrc)
        '';
    }
  else homies
