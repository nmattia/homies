# Tmux with ./tmux.conf baked in
{ tmux, writeText, symlinkJoin, makeWrapper }:
symlinkJoin {
  paths = [ tmux ];
  postBuild = ''
    wrapProgram "$out/bin/tmux" \
    --add-flags "-f ${./tmux.conf}"
  '';
  name = "tmux";
  buildInputs = [makeWrapper];
}
