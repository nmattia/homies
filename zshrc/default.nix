# Because the path of the zshrc changes upon rebuild, we cannot source it
# directly from the (vanilla) ~/.zshrc.
# Instead we read it from ~/.nix-profile.
{ lib, runCommand, writeText, writeScriptBin, fzf, nix, cacert, nixpkgs-src }:
let
  # Write .zshrc to share/zshrc/zshrc
  zshrc = writeText "zshrc"
    (lib.concatStringsSep "\n"
      [ # Set up nix autocomplete
        ''
          fpath+=(${nix}/share/zsh/site-functions)
        ''
        (builtins.readFile ./zshrc)
        # Set up fzf terminal bindings
        ''
          source ${fzf}/share/fzf/completion.zsh
          source ${fzf}/share/fzf/key-bindings.zsh
        ''
        # Set up useful env vars (NIX_PATH to have a set nixpkgs,
        # and SSL_CERT_FILE make sure https works)
        ''
          export NIX_PATH=nixpkgs=${nixpkgs-src}
          export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
        ''
      ]
    );
in

runCommand "zshrc" { } ''
  mkdir -p $out/share/zshrc
  cp ${zshrc} $out/share/zshrc/zshrc
''
