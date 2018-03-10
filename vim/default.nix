{ symlinkJoin, makeWrapper, vim_configurable, vimUtils, vimPlugins, haskellPackages }:
let
  pluginDictionaries = with vimPlugins;
    [
      # TODO: setup ultisnips
      # ghcmod # NOTE: the haskell package for ghc-mod is broken
      ctrlp
      fugitive
      gitgutter
      nerdcommenter
      nerdtree
      surround
      syntastic
      tmux-navigator
      vim-airline
      vim-indent-guides
      vim-markdown
      vim-multiple-cursors
      vim-nix
      vim-trailing-whitespace
      vimproc
      youcompleteme
    ];
  customRC = builtins.readFile ./vimrc ;
in
symlinkJoin {
  paths = [ vim_configurable ];
  postBuild = ''
    wrapProgram "$out/bin/vim" \
    --add-flags "-u ${vimUtils.vimrcFile {
      packages.mvc.start = pluginDictionaries;
      inherit customRC;
    }}" \
      --prefix PATH : ${haskellPackages.hasktags}/bin
  '';
  name = "vim";
  buildInputs = [makeWrapper];
}
