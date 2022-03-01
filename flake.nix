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
      lib = nixpkgs.lib;
      mkOutputsFor = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          vimPlugins = { inherit vim-nix nvim-tree fzf-vim; };
          packages = import ./packages.nix {
            nixpkgs-src = nixpkgs;
            inherit
              pkgs
              vimPlugins
              git-src
              niv-src;
          };

        in
        {
          devShell = pkgs.mkShell {
            nativeBuildInputs = [ packages.homies ];
            shellHook = ''
              $(bashrc)
              PS1=" $PS1"
            '';
          };

          defaultPackage = packages.homies;
        };
    in
    flake-utils.lib.eachSystem [ "x86_64-darwin" ] mkOutputsFor;
}
