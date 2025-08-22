{ runCommand, lib, makeWrapper, coreutils, neovim-unwrapped, symlinkJoin, fzf, inputs, ripgrep }:
let
  plugins = {
    inherit (inputs)
      fugitive
      bufdelete-nvim
      bufferline-nvim
      multicursor-nvim
      nvim-tree
      nvim-web-devicons
      openingh
      vim-astro
      vim-glsl
      vim-nix
      vim-submode
      vim-surround
      vim-svelte
      vim-terraform;
  };

  plugins' = lib.mapAttrsToList (k: v: "${k} ${v}") plugins;
  plugins'' = lib.concatStringsSep "\n" plugins';

  pluginsDir = runCommand "mk-plugins" { nativeBuildInputs = [ neovim-unwrapped ]; }
    ''
      plugins_dir="$out/pack/nix-is-an-addiction/start"

      mkdir -p "$plugins_dir"

      # loop over plugins, using FD 10 to avoid polluting stdin
      # (trips nvim otherwise)
      while read -u 10 plug_name plugin
      do
        plug_dest="$plugins_dir/$plug_name"

        echo installing plugin
        echo "   " name "'$plug_name'"
        echo "   " source "'$plugin'"
        echo "   " destination "'$plug_dest'"

        cp -a "$plugin/." "$plug_dest"

        # build doc/helptags if necessary
        pushd "$plug_dest" >/dev/null
        if [ -d doc ]
        then
          echo installing doc
          chmod -R +w .
          # Set home & al so that nvim can create swapfiles
          XDG_DATA_HOME=$PWD HOME=$PWD nvim -u NONE -c ":helptags doc" -c q
        fi
        popd >/dev/null
      done 10<<< $(echo -n "${plugins''}")
    '';

  luafun = runCommand "luafun" { } ''
    mkdir -p $out
    cp ${inputs.luafun}/fun.lua $out/fun.lua
  '';

  extraBins = [
    ripgrep # used by fzf.lua for rg
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
      --set NEOVIM_LUA_PATH '${luafun}/?.lua;${./lua}/?.lua' \
      --prefix PATH ':' '${lib.makeBinPath extraBins}'
  '';
  paths = [ neovim-unwrapped ];
}
