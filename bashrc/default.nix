# Because the path of the bashrc changes upon rebuild, we cannot source it
# directly from the (vanilla) ~/.bashrc. Instead this script is created, which
# will source the latest bashrc.
#
# The bashrc script should be evaluated from the actual ~/.bashrc:
#   if [ -x "$(command -v bashrc)" ]; then $(bashrc); fi
{ lib, writeText, writeScriptBin, fzf }:
let
  bashrc = writeText "bashrc"
    (lib.concatStringsSep "\n"
    [ (builtins.readFile ./bashrc)
      ''
      source ${fzf}/share/fzf/completion.bash
      source ${fzf}/share/fzf/key-bindings.bash
      ''
    ]
    );
in writeScriptBin "bashrc"
  ''
    echo ". ${bashrc}"
  ''
