{ kitty, inputs, runCommand, writeText, writeScriptBin }:

# Wrapped kitty terminal emulator, different from stock:
#  * We create a dummy macos bundle with a custom icon. The bundle points to
#     ~/.nix-profile and should only rarely need to be updated.
#  * The actual `kitty` executable in PATH is a shell wrapper that sets custom
#     configuration (kitty.conf, startup args)

let
  kittyConfDir = runCommand "kitty-conf" { } ''
    mkdir -p $out
    cp ${./kitty.conf} $out/kitty.conf
  '';

  # kitty uses $0/_NSGetExecutablePath to figure out the path of its
  # bundle so (on macOS) kitty should find the correct set of resources (except
  # for the icon, but the icon is only relevant to macOS when reading the bundle)
  wrapper = writeScriptBin "kitty" ''
    #!/usr/bin/env bash

    export KITTY_CONFIG_DIRECTORY=${kittyConfDir}
    export HOMIES_KITTY_SCRIPTS=${./scripts}
    exec ${kitty}/bin/kitty --start-as=fullscreen "$@"
  '';


  # Actual runner injected in the bundle
  kittyProfileRunner = writeText "kittyexe" ''
    #!/usr/bin/env bash
    kitty_exe="$HOME/.nix-profile/bin/kitty"

    if ! [ -e "$kitty_exe" ]; then echo "kitty not found"; exit 1; fi
    exec -a kitty $kitty_exe
  '';

  bundle = runCommand "kitty-0" { } ''
    bundle=$out/Applications/kitty.app
    mkdir -p $bundle

    mkdir -p $bundle/Contents
    cat <${kitty}/Applications/kitty.app/Contents/Info.plist \
      > $bundle/Contents/Info.plist

    mkdir -p $bundle/Contents/MacOS
    cat <${kittyProfileRunner} > $bundle/Contents/MacOS/kitty
    chmod +x $bundle/Contents/MacOS/kitty

    mkdir -p $bundle/Contents/Resources/
    cat <${inputs.kitty-icon}/build/neue_toxic.icns > $bundle/Contents/Resources/kitty.icns

  '';

in
{ inherit bundle wrapper; }
