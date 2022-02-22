# Git, with a git config baked in (see ./config)
{ runCommand, git, symlinkJoin, makeWrapper, writeTextFile, git-src }:
let
  myGit = git.overrideAttrs (old: {

    # git has three levels of config: system, global, and local. The nixpkgs build
    # of git already writes some stuff to the system config, so we just append our
    # own config. The big drawback is that we need to build git from scratch.
    postInstall = old.postInstall + ''
      cat ${gitconfig} >> $out/etc/gitconfig
    '';
  });

  gitconfig = writeTextFile
    {
      name = "git-config";
      text =
        builtins.replaceStrings
          [ "SUBSTITUTE_GITIGNORE" ] [ "${./gitignore}" ]
          (builtins.readFile ./gitconfig);
    };

  completion = runCommand "git-completion" { }
    ''
      mkdir -p $out/etc/bash_completion.d/
      cp ${git-src}/contrib/completion/git-completion.bash $out/etc/bash_completion.d/git-completion.sh
    '';
in

symlinkJoin {
  name = "git";
  paths = [ myGit completion ];
}
