# Git, with a git config baked in (see ./config)
{ git, symlinkJoin, makeWrapper }:
symlinkJoin {
  name = "git";
  buildInputs = [makeWrapper];
  paths = [ git ];
  postBuild = ''
    wrapProgram "$out/bin/git" \
    --set GIT_CONFIG "${./config}"
  '';
}
