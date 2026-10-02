{ inputs, sources, runCommand, writeText, clang, writeScriptBin, _7zz }:

# This creates a derivation with the Kitty version specified in the sources as well as a custom config.

let

  # NOTE: we use the official kitty build because it is signed & notarized by the author. Unless signed,
  # kitty can't trigger notifications on macOS.
  version = sources.kitty-darwin.version;
  sha256 = sources.kitty-darwin.sha256;
  kittyDmg = builtins.fetchurl {
    url = sources.kitty-darwin.url;
    inherit sha256;
  };

  # creates `$out/Applications` that gets picked up by buildEnv
  appBundle = runCommand "kitty" { nativeBuildInputs = [ _7zz ]; } ''
    mkdir -p "$out/Applications"
    cd $out/Applications
    7zz x -snld ${kittyDmg} # -snld: required to allow internal symlinks
    if [ -L ./Applications ]; then
        # kitty includes a symlink to Applications for easy drag and drop.
        # we really don't care about that here
        rm ./Applications
    fi
  '';

  # creates `$out/share/kitty` that gets picked up by buildEnv
  conf = runCommand "kitty-share" { } ''
    mkdir -p $out/share/kitty
    cat ${./kitty.conf} > $out/share/kitty/kitty.conf
    echo '--start-as=fullscreen' > $out/share/kitty/macos-launch-services-cmdline
  '';

in
{ inherit appBundle conf; }
