# Git, with a git config baked in (see ./config)
{ git, symlinkJoin, makeWrapper, writeTextFile }:
with
  { gitHome = writeTextFile
      { name = "git-config";
        text = builtins.readFile ./config;
        destination = "/.gitconfig";
      };
  };

symlinkJoin {
  name = "git";
  buildInputs = [makeWrapper];
  paths = [ git ];
  postBuild = ''
    wrapProgram "$out/bin/git" \
    --set HOME "${gitHome}"
  '';
}
