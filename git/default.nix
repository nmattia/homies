# Git, with a git config baked in (see ./config)
{ runCommand, git, symlinkJoin, writeTextFile }:
let

  gitconfig = writeTextFile
    {
      name = "git-config";
      text =
        builtins.replaceStrings
          [ "SUBSTITUTE_GITIGNORE" ] [ "${./gitignore}" ]
          (builtins.readFile ./gitconfig);
    };
in

git.overrideAttrs (old: {

  # git has three levels of config: system, global, and local. The nixpkgs build
  # of git already writes some stuff to the system config, so we just append our
  # own config. The big drawback is that we need to build git from scratch.
  postInstall = old.postInstall + ''
    cat ${gitconfig} >> $out/etc/gitconfig
  '';
})
