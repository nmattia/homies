{ kitty, makeWrapper, symlinkJoin, stdenv, lib, inputs, runCommand }:


kitty.overrideAttrs (oldAttrs: {

  # Replace the icons with something a bit more modern
  # NOTE: we don't use the official guidelines (putting .icns in the conf dir)
  # because that only works temporarily. Instead we replace the icons in the
  # source (bit more drastic even than replacing the icons in kitty.app after build)
  preBuild = ''
    rm -r ./logo/kitty.iconset
    cp -r ${inputs.kitty-icon}/build/neue_azure.iconset ./logo/kitty.iconset

    rm ./logo/kitty.png
    cp ${inputs.kitty-icon}/build/neue_azure.iconset/icon_256x256.png ./logo/kitty.png

    rm ./logo/kitty-128.png
    cp ${inputs.kitty-icon}/build/neue_azure.iconset/icon_128x128.png ./logo/kitty-128.png
    '';
  installPhase =
    # Add some args to the kitty launcher
    let
      oldWrapPrograms = lib.filter (lib.hasPrefix "wrapProgram") (lib.splitString "\n" oldAttrs.installPhase);
      oldWrapProgram = (lib.elemAt oldWrapPrograms 0);
      kittyConfDir = runCommand "kitty-conf" { } ''
        mkdir -p $out
        cp ${./kitty.conf} $out/kitty.conf
      '';
      newWrapProgram = "${oldWrapProgram} --set KITTY_CONFIG_DIRECTORY ${kittyConfDir}";
    in

    lib.replaceStrings [ oldWrapProgram ] [ newWrapProgram ] oldAttrs.installPhase;
})
