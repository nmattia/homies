{ runCommand, lib, makeWrapper, coreutils, neovim-unwrapped, symlinkJoin, fzf, inputs, ripgrep }:
let
  plugins = [
    inputs.nvim-tree
    inputs.vim-nix
    inputs.fugitive
    inputs.vim-surround
    inputs.vim-svelte
    "${fzf}/share/vim-plugins/fzf"
  ];

  pluginsDir = runCommand "mk-plugins" { nativeBuildInputs = [ neovim-unwrapped ]; }
    ''
      mkdir -p $out/pack/nix-is-an-addiction/start

      for plugin in ${lib.concatStringsSep " " plugins}
      do
        plug_dest="$out/pack/nix-is-an-addiction/start/$(basename $plugin)"

        # install plugin
        cp -a "$plugin/." "$plug_dest"
        pushd "$plug_dest"

        # build doc/helptags if necessary
        if [ -d doc ]
        then
          chmod -R +w .
          # Set home & al so that nvim can create swapfiles
          XDG_DATA_HOME=$PWD HOME=$PWD nvim -u NONE -c ":helptags doc" -c q
        fi
        popd
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
