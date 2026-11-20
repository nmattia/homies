{ sources, runCommand, xar, cpio, ... }:

# This creates a derivation with the apple/container version specified in the sources.

let

  # NOTE: we use the official installer package because its binaries are signed by Apple. The
  # runtime and vmnet plugins need the 'com.apple.security.virtualization' entitlement.
  #
  # The .pkg is a plain payload (no install scripts) meant for /usr/local; we only unpack it.
  # Layout matters: 'container' finds its plugins relative to its own path
  # (<bin>/../libexec/container/plugins), so bin/ and libexec/ must stay side by side.
  version = sources.apple-container.version;
  sha256 = sources.apple-container.sha256;
  containerPkg = builtins.fetchurl {
    url = sources.apple-container.url;
    inherit sha256;
  };

in

# NOTE: runCommand only runs the given script (no fixup phase), so binaries are not stripped or
  # patched and the code signatures stay intact.
runCommand "container-${version}" { nativeBuildInputs = [ xar cpio ]; } ''
  xar -xf ${containerPkg} Payload
  gunzip -dc Payload | cpio -i --quiet

  mkdir -p $out/bin $out/libexec
  # skip bin/{update,uninstall}-container.sh, which assume an /usr/local install
  cp -a bin/container bin/container-apiserver $out/bin/
  cp -a libexec/container $out/libexec/
''
