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
      snack
      tmux
      vim
      python

      pkgs.curl
      pkgs.fzf
      pkgs.gnupg
      pkgs.htop
      pkgs.jq
      pkgs.less
      pkgs.niv
      pkgs.nix
      pkgs.pass
      pkgs.tree
      pkgs.xclip
    ];

  ## Some cunstomizations
  python = pkgs.python.withPackages (ps: [ ps.grip ]);

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = pkgs.callPackage ./bashrc {};

  # Git with config baked in
  git = import ./git (
    { inherit (pkgs) makeWrapper symlinkJoin;
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

  snack = (import pkgs.sources.snack).snack-exe;

  # Vim with a custom vimrc and set of packages
  vim = import ./vim
    { inherit (pkgs)
        haskellPackages
        makeWrapper
        symlinkJoin
        vimPlugins
        vimUtils
        vim_configurable;
      inherit
        git
        tmux;
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
