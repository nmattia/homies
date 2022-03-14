{ runCommand, lib, makeWrapper, coreutils, neovim-unwrapped, symlinkJoin, fzf, inputs, ripgrep }:
let
  pluginsDir = runCommand "mk-plugins" { nativeBuildInputs = [ neovim-unwrapped ]; }
    ''
      mkdir -p $out/pack/nix-is-an-addiction/start

      cp -a ${inputs.nvim-tree}/. $out/pack/nix-is-an-addiction/start/nvim-tree
      cp -a ${inputs.vim-nix}/. $out/pack/nix-is-an-addiction/start/vim-nix
      cp -a ${inputs.fzf-vim}/. $out/pack/nix-is-an-addiction/start/fzf.vim

      mkdir -p $out/pack/fzf/start
      ln -s ${fzf}/share/vim-plugins/fzf $out/pack/fzf/start/fzf

      for plugin in $out/pack/nix-is-an-addiction/start/*
      do
        cd "$plugin"
        if [ -d doc ]
        then
          chmod -R +w .
          XDG_DATA_HOME=$PWD nvim -u NONE -c ":helptags doc" -c q
        fi
      done
    '';
  extraBins = [
      ripgrep # used by fzf.vim for `:Rg`
      coreutils
    ];
in

symlinkJoin {
  name = "neovim";
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/nvim" \
    --add-flags "-u ${./init.lua}" \
      --set NEOVIM_PLUGINS_PATH '${pluginsDir}' \
      --set NEOVIM_LUA_PATH '${./lua}' \
      --prefix PATH ':' '${lib.makeBinPath extraBins}'
  '';
  paths = [ neovim-unwrapped ];
}
