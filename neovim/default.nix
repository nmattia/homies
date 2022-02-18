{ runCommand, writeText, makeWrapper, coreutils, neovim-unwrapped, symlinkJoin }:

let nvimtree = builtins.fetchTarball https://github.com/kyazdani42/nvim-tree.lua/archive/refs/heads/master.zip; in

let nvimtreeicons = builtins.fetchTarball https://github.com/kyazdani42/nvim-web-devicons/archive/refs/heads/master.zip; in

let vim-tmux-navigator = builtins.fetchTarball https://github.com/christoomey/vim-tmux-navigator/archive/refs/heads/master.zip; in

let vim-nix = builtins.fetchTarball https://github.com/LnL7/vim-nix/archive/refs/heads/master.zip; in

let
  pluginsDir = runCommand "mk-plugins" { }
    ''
      mkdir -p $out/pack/nix-is-an-addiction/start

      cp -a ${nvimtree}/. $out/pack/nix-is-an-addiction/start/nvim-tree
      cp -a ${nvimtreeicons}/. $out/pack/nix-is-an-addiction/start/nvim-web-devicons
      cp -a ${vim-tmux-navigator}/. $out/pack/nix-is-an-addiction/start/vim-tmux-navigator
      cp -a ${vim-nix}/. $out/pack/nix-is-an-addiction/start/vim-nix

    '';
in

# neovim will load plugins from `plugin/` of any dir specified on
  # `runtimepath`.
let
  rc = ''
    let mapleader=","
    set packpath+=${pluginsDir} " TODO: set through env var
    lua require'nvim-tree'.setup{}
    nnoremap <Leader>o :NvimTreeToggle<CR>

    nnoremap <C-J> <C-W><C-J>
    nnoremap <C-K> <C-W><C-K>
    nnoremap <C-L> <C-W><C-L>
    nnoremap <C-H> <C-W><C-H>
  '';
in

symlinkJoin {
  name = "neovim";
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/nvim" \
    --add-flags "-u ${writeText "init.vim" rc}" \
      --prefix PATH ':' '${coreutils}/bin'
  '';
  paths = [ neovim-unwrapped ];
}
