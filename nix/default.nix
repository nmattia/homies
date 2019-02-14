{ sources ? import ./sources.nix }:
with
  { overlay = _: pkgs:
      { inherit (import sources.niv {}) niv;
        sources = sources;
      };
  };
import sources.nixpkgs
  { overlays = [ overlay ] ; config = {}; }
