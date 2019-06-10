{ sources, pkgs }:
with rec
{ napalm = pkgs.callPackage sources.napalm {};
  bwDrv = napalm.buildPackage sources.bitwarden-cli
    { npmCommands = [ "npm install" "npm run build" ]; };
  bw = bwDrv.overrideAttrs (oldAttrs:
    { postUnpack =
        ''
          rmdir $sourceRoot/jslib
          cp -r ${sources.bitwarden-jslib} $sourceRoot/jslib
        '';
    }
    );
};

bw
