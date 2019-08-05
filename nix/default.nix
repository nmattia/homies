{ sources ? import ./sources.nix }:

let
  overlay = super: pkgs:
      { niv = pkgs.haskell.lib.justStaticExecutables (import sources.niv {}).niv;
        sources = sources;
        rusty-tags =
          let naersk = super.callPackage sources.naersk {}; in
          naersk.buildPackage sources.rusty-tags { doDoc = false; };
      };
in
import sources.nixpkgs
  { overlays = [ overlay ] ; config = {}; }
