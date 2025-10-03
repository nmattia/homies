{ inputs, runCommand, writeText, writeScriptBin, _7zz }:

# Wrapped kitty terminal emulator, different from stock:
#  * We create a dummy macos bundle with a custom icon. The bundle points to
#     ~/.nix-profile and should only rarely need to be updated.
#  * The actual `kitty` executable in PATH is a shell wrapper that sets custom
#     configuration (kitty.conf, startup args)

let

  # NOTE: we use the official kitty build because it is signed & notarized by the author. Unless signed,
  # kitty can't trigger notifications on macOS.
  version = "0.43.1";
  sha256 = "sha256:1al7m5p9p9v93gvqrh368vgdglhp7zmsbv5r9ygb99xs7h7qyvg3";
  kittyDmg = builtins.fetchurl {
    url = "https://github.com/kovidgoyal/kitty/releases/download/v${version}/kitty-${version}.dmg";
    inherit sha256;
  };
  kitty = runCommand "kitty" { nativeBuildInputs = [ _7zz ]; } ''
    mkdir -p "$out/Applications"
    cd $out/Applications
    7zz x -snld ${kittyDmg} # -snld: required to allow internal symlinks
  '';

  kittyConfDir = runCommand "kitty-conf" { nativeBuildInputs = [ _7zz ]; } ''
    mkdir -p $out
    cp ${./kitty.conf} $out/kitty.conf
  '';

  # kitty uses $0/_NSGetExecutablePath to figure out the path of its
  # bundle so (on macOS) kitty should find the correct set of resources (except
  # for the icon, but the icon is only relevant to macOS when reading the bundle)
  wrapper = writeScriptBin "kitty" ''
    #!/usr/bin/env bash

    export KITTY_CONFIG_DIRECTORY=${kittyConfDir}
    exec ${kitty}/Applications/kitty.app/Contents/MacOS/kitty --start-as=fullscreen "$@"
  '';


  # Actual runner injected in the bundle
  # NOTE: KITTY_LAUNCHED_BY_LAUNCH_SERVICES=1 tells kitty to change dir to HOME
  kittyProfileRunner = writeText "kittyexe" ''
    #!/usr/bin/env bash
    kitty_exe="$HOME/.nix-profile/bin/kitty"

    if ! [ -e "$kitty_exe" ]; then echo "kitty not found"; exit 1; fi
    exec -a kitty env KITTY_LAUNCHED_BY_LAUNCH_SERVICES=1 $kitty_exe
  '';

  bundle = runCommand "kitty-0" { } ''
    bundle=$out/Applications/kitty.app
    mkdir -p $bundle

    mkdir -p $bundle/Contents
    cat <${./Info.plist} > $bundle/Contents/Info.plist

    mkdir -p $bundle/Contents/MacOS
    cat <${kittyProfileRunner} > $bundle/Contents/MacOS/kitty
    chmod +x $bundle/Contents/MacOS/kitty

    mkdir -p $bundle/Contents/Resources/
    cat <${inputs.kitty-icon}/build/neue_toxic.icns > $bundle/Contents/Resources/kitty.icns

  '';

in
{ inherit bundle wrapper; }
