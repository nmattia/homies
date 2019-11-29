{ sources ? import ./sources.nix }:

let
  overlay = self: super:
      { niv = self.haskell.lib.justStaticExecutables (import sources.niv {}).niv;
        sources = sources;
        # This is used by ycmd -> youcompleteme -> vim and the fix wasn't
        # backported to 19.09
        rustracerd = super.rustracerd.overrideAttrs (oa:
          {
            nativeBuildInputs = (oa.nativeBuildInputs or []) ++ [ self.makeWrapper ];
            buildInputs = (oa.buildInputs or []) ++ self.stdenv.lib.optional self.stdenv.isDarwin self.darwin.Security;
          }
          );
      };
in
import sources.nixpkgs
  { overlays = [ overlay ] ; config = {}; }
