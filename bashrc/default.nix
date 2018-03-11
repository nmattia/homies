{writeScriptBin}:
writeScriptBin "bashrc"
  ''
    echo ". ${./bashrc}"
  ''
