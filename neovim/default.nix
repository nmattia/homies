{ runCommand, writeText, makeWrapper, coreutils, neovim-unwrapped, symlinkJoin, fzf }:

let nvimtree = builtins.fetchTarball https://github.com/kyazdani42/nvim-tree.lua/archive/refs/heads/master.zip; in

let nvimtreeicons = builtins.fetchTarball https://github.com/kyazdani42/nvim-web-devicons/archive/refs/heads/master.zip; in

let vim-tmux-navigator = builtins.fetchTarball https://github.com/christoomey/vim-tmux-navigator/archive/refs/heads/master.zip; in

let vim-nix = builtins.fetchTarball https://github.com/LnL7/vim-nix/archive/refs/heads/master.zip; in

let fzf-vim = builtins.fetchTarball https://github.com/junegunn/fzf.vim/archive/refs/heads/master.zip; in

let
  pluginsDir = runCommand "mk-plugins" { }
    ''
      mkdir -p $out/pack/nix-is-an-addiction/start

      cp -a ${nvimtree}/. $out/pack/nix-is-an-addiction/start/nvim-tree
      cp -a ${vim-tmux-navigator}/. $out/pack/nix-is-an-addiction/start/vim-tmux-navigator
      cp -a ${vim-nix}/. $out/pack/nix-is-an-addiction/start/vim-nix
      cp -a ${fzf-vim}/. $out/pack/nix-is-an-addiction/start/fzf.vim

      mkdir -p $out/pack/fzf/start
      ln -s ${fzf}/share/vim-plugins/fzf $out/pack/fzf/start/fzf
    '';
in

symlinkJoin {
  name = "neovim";
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/nvim" \
    --add-flags "-u ${./init.vim}" \
      --set NEOVIM_PLUGINS_PATH '${pluginsDir}' \
      --prefix PATH ':' '${coreutils}/bin'
  '';
  paths = [ neovim-unwrapped ];
}
