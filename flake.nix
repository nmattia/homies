{
  description = "my project description";

  inputs.flake-compat = {
    url = github:edolstra/flake-compat;
    flake = false;
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.vim-nix.url = "github:LnL7/vim-nix";
  inputs.vim-nix.flake = false;

  inputs.vim-svelte.url = "github:evanleck/vim-svelte";
  inputs.vim-svelte.flake = false;

  inputs.vim-terraform.url = "github:hashivim/vim-terraform";
  inputs.vim-terraform.flake = false;

  inputs.nvim-tree.url = "github:kyazdani42/nvim-tree.lua";
  inputs.nvim-tree.flake = false;

  inputs.git-src.url = "github:git/git";
  inputs.git-src.flake = false;

  inputs.niv-src.url = "github:nmattia/niv";
  inputs.niv-src.flake = false;

  inputs.fugitive.url = "github:tpope/vim-fugitive";
  inputs.fugitive.flake = false;

  inputs.vim-astro.url = "github:wuelnerdotexe/vim-astro";
  inputs.vim-astro.flake = false;

  inputs.vim-surround.url = github:tpope/vim-surround;
  inputs.vim-surround.flake = false;

  inputs.luafun.url = github:luafun/luafun;
  inputs.luafun.flake = false;

  outputs =
    inputs@{ self
    , nixpkgs
    , flake-compat
    , flake-utils
    , git-src
    , niv-src
    , ...
    }:
    let
      lib = nixpkgs.lib;
      mkOutputsFor = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          packages = import ./packages.nix {
            nixpkgs-src = nixpkgs;
            inherit
              pkgs
              inputs
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
    flake-utils.lib.eachSystem [ "x86_64-darwin" "aarch64-darwin" ] mkOutputsFor;
}
