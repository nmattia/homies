{
  description = "my project description";

  inputs.flake-compat = {
    url = github:edolstra/flake-compat;
    flake = false;
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.vim-nix.url = "github:LnL7/vim-nix";
  inputs.vim-nix.flake = false;

  inputs.nvim-tree.url = "github:kyazdani42/nvim-tree.lua";
  inputs.nvim-tree.flake = false;

  inputs.fzf-vim.url = "github:junegunn/fzf.vim";
  inputs.fzf-vim.flake = false;

  inputs.git-src.url = "github:git/git";
  inputs.git-src.flake = false;

  inputs.niv-src.url = "github:nmattia/niv";
  inputs.niv-src.flake = false;

  outputs =
    { self
    , nixpkgs
    , flake-compat
    , flake-utils
    , vim-nix
    , nvim-tree
    , fzf-vim
    , git-src
    , niv-src
    }:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      system = "aarch64-darwin";
      vimPlugins = { inherit vim-nix nvim-tree fzf-vim; };
      packages = import ./packages.nix {
        inherit
          pkgs
          nixpkgs
          vimPlugins
          system
          git-src
          niv-src;
      };
    in
    {
      devShell.${system} = pkgs.mkShell {
        nativeBuildInputs = [ packages.homies ];
        shellHook = ''
          $(bashrc)
          PS1=" $PS1"
          '';
      };

      defaultPackage.${system} = packages.homies;
    };
}
