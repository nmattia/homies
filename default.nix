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
      tmux
      vim
      python

      pkgs.curl
      pkgs.fzf
      pkgs.gnupg
      pkgs.haskellPackages.wai-app-static
      pkgs.htop
      pkgs.jq
      pkgs.less
      pkgs.niv
      pkgs.nix
      pkgs.nix-diff
      pkgs.pass
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

  rusty-tags =
    let naersk = pkgs.callPackage pkgs.sources.naersk {}; in
    naersk.buildPackage
      { src = pkgs.sources.rusty-tags;
        doDoc = false;
      };

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
