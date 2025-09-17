# gitconfig file
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

runCommand "gitconfig" { } ''
  mkdir -p $out/share/git
  cp ${gitconfig} $out/share/git/gitconfig
''
