{ sources ? import ./sources.nix }:
with
  { overlay = _: pkgs:
      { niv = pkgs.haskell.lib.justStaticExecutables (import sources.niv {}).niv;
        sources = sources;
      };
  };
import sources.nixpkgs
  { overlays = [ overlay ] ; config = {}; }
