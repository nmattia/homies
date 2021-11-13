# Vim, with a set of extra packages (extraPackages) and a custom vimrc
# (./vimrc). The final vimrc file is generated by vimUtils.vimrcFile and
# bundles all the packages with the custom vimrc.
{ sources
, git
, coreutils
, cargo
, tmux
, symlinkJoin
, makeWrapper
, vim_configurable
, vimUtils
, vimPlugins
, haskellPackages
#, rusty-tags
, lib
, ctags
, python37
, stdenv
}:
let
  vim = if stdenv.isDarwin then vim_configurable.overrideAttrs (
    oa:
      {
        configureFlags = lib.filter
          (f: ! lib.hasPrefix "--enable-gui" f) oa.configureFlags;
      }
  ) else vim_configurable;

  extraPackages = with vimPlugins;
    [

      ctrlp
      elm-vim
      fugitive
      nerdcommenter
      nerdtree
      purescript-vim
      surround
      syntastic
      #tmux-navigator
      vim-airline
      vim-colorschemes
      vim-easymotion
      vim-indent-guides
      vim-markdown
      vim-multiple-cursors
      vim-nix
      vim-toml
      vim-tmux-navigator
      vim-trailing-whitespace
      vimproc
      YouCompleteMe
      (
        vimUtils.buildVimPlugin
          {
            name = "vim-terraform";
            src = sources.vim-terraform;
            buildPhase = ":";
          }
      )

    ];
  customRC = vimUtils.vimrcFile
    {
      customRC = builtins.readFile ./vimrc;
      packages.mvc.start = extraPackages;
    };
in
symlinkJoin {
  name = "vim";
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/vim" \
    --add-flags "-u ${customRC}" \
      --prefix PATH ':' '${python37}/bin:${coreutils}/bin:${cargo}/bin:${ctags}/bin:${git}/bin:${tmux}/bin'
  '';
  paths = [ vim ];
}
