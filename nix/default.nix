{ system ? builtins.currentSystem, sources ? import ./sources.nix { inherit system; } }:

let
  overlay = self: super:
    {
      niv = self.haskell.lib.justStaticExecutables (import sources.niv { pkgs = self; }).niv;
      inherit sources;
    };
in
import sources.nixpkgs
{ overlays = [ overlay ]; config = { }; inherit system; }
