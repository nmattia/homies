# The main homies file, where homies are defined. See the README.md for
# instructions.
let

  # The (pinned) Nixpkgs where the original packages are sourced from
  pkgs = import ./nixpkgs {};

  # The list of packages to be installed
  homies = with pkgs;
    [
      # Customized packages
      bashrc
      git
      tmux
      vim

      pkgs.curl
      pkgs.gitAndTools.gitAnnex
      pkgs.htop
      pkgs.jq
      pkgs.less
      pkgs.nix
      pkgs.pass
      pkgs.tree
      pkgs.xclip
    ];

  ## Some cunstomizations

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = import ./bashrc (with pkgs;
    { inherit
        writeScriptBin
        ;
    });

  # Git with config baked in
  git = import ./git (with pkgs;
    { inherit
        makeWrapper
        symlinkJoin
        ;
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


  # Vim with a custom vimrc and set of packages
  vim = import ./vim (with pkgs;
    {inherit
        symlinkJoin
        makeWrapper
        vim_configurable
        vimUtils
        vimPlugins
        haskellPackages;
    });

in
  if pkgs.lib.inNixShell
  then pkgs.mkShell
    { buildInputs = homies;
      shellHook = ''
        $(bashrc)
        '';
    }
  else homies
