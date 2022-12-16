# Nix, with a nix.conf baked in
{ nix, symlinkJoin, makeWrapper }:

symlinkJoin {
  name = "nix";
  nativeBuildInputs = [ makeWrapper ];
  paths = [ nix ];
  postBuild = ''
    wrapProgram $out/bin/nix \
      --set NIX_USER_CONF_FILES ${./nix.conf}
  '';
}
