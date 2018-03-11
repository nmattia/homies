# Bake our git config in git
{ git, symlinkJoin, makeWrapper }:
symlinkJoin {
  paths = [ git ];
  postBuild = ''
    wrapProgram "$out/bin/git" \
    --set GIT_CONFIG "${./config}"
  '';
  name = "git";
  buildInputs = [makeWrapper];
}
