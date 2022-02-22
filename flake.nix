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

  outputs = { self, nixpkgs, flake-compat, flake-utils, vim-nix, nvim-tree, fzf-vim, git-src }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      system = "aarch64-darwin";
      vimPlugins = { inherit vim-nix nvim-tree fzf-vim; };
      packages = import ./packages.nix { inherit vimPlugins system git-src; };
    in
    {
      devShell.${system} = pkgs.mkShell {
        nativeBuildInputs = [ packages.homies ];
        shellHook = "$(bashrc)";
      };

      defaultPackage.${system} = packages.homies;

      packages.${system} = packages;
    };
}
