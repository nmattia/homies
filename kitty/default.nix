{ kitty, makeWrapper, symlinkJoin, stdenv, lib }:


kitty.overrideAttrs (oldAttrs: {
  installPhase =
    # Add some args to the kitty launcher
    let
      oldWrapPrograms = lib.filter (lib.hasPrefix "wrapProgram") (lib.splitString "\n" oldAttrs.installPhase);
      oldWrapProgram = (lib.elemAt oldWrapPrograms 0);
      newWrapProgram = "${oldWrapProgram} --add-flags '--config ${./kitty.conf}'";
    in

    lib.replaceStrings [ oldWrapProgram ] [ newWrapProgram ] oldAttrs.installPhase;

})
