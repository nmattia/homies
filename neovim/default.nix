{ runCommand, makeWrapper, coreutils, neovim-unwrapped, symlinkJoin, fzf, vimPlugins }:

let
  pluginsDir = runCommand "mk-plugins" { nativeBuildInputs = [ neovim-unwrapped ]; }
    ''
      mkdir -p $out/pack/nix-is-an-addiction/start

      cp -a ${vimPlugins.nvim-tree}/. $out/pack/nix-is-an-addiction/start/nvim-tree
      cp -a ${vimPlugins.vim-nix}/. $out/pack/nix-is-an-addiction/start/vim-nix
      cp -a ${vimPlugins.fzf-vim}/. $out/pack/nix-is-an-addiction/start/fzf.vim

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
