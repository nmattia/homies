{ system ? builtins.currentSystem, sources ? import ./sources.nix { inherit system; } , niv-src }:

let
  overlay = self: super:
    {
      niv = self.haskell.lib.justStaticExecutables (import niv-src { pkgs = self; }).niv;
      inherit sources;
    };
in
import sources.nixpkgs
{ overlays = [ overlay ]; config = { }; inherit system; }
