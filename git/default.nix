# Git, with a git config baked in (see ./config)
{ sources, runCommand, git, symlinkJoin, makeWrapper, writeTextFile, git-src }:
let
  gitHome = writeTextFile
    {
      name = "git-config";
      text =
        builtins.replaceStrings
          [ "SUBSTITUTE_GITIGNORE" ] [ "${./gitignore}" ]
          (builtins.readFile ./config);
      destination = "/.gitconfig";
    };
  completion = runCommand "git-completion" { }
    ''
      mkdir -p $out/etc/bash_completion.d/
      cp ${git-src}/contrib/completion/git-completion.bash $out/etc/bash_completion.d/git-completion.sh
    '';
in

symlinkJoin {
  name = "git";
  buildInputs = [ makeWrapper ];
  paths = [ git completion ];
  postBuild = ''
    wrapProgram "$out/bin/git" \
    --set HOME "${gitHome}"
  '';
}
