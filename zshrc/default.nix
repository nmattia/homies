# Because the path of the zshrc changes upon rebuild, we cannot source it
# directly from the (vanilla) ~/.zshrc.
# Instead we read it from ~/.nix-profile.
{ lib, stdenv, runCommand, writeText, writeScriptBin, fzf, nix, nixpkgs-src }:
let

  # official git completion, better & faster than the zsh defaults
  git-completion-zsh-src = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/git/git/3c20acdf465ba211978108ca8507d41e62a016fd/contrib/completion/git-completion.zsh";
    sha256 = "sha256:0cifmyc0rsf1pn0lr4qpkgwcb2l7dxk8nqbd7xdc9ij3jq34ijnf";
  };
  git-completion-zsh = runCommand "git-completion-zsh" { } ''
    mkdir -p $out/git-completion.zsh/
    cat <${git-completion-zsh-src} > $out/git-completion.zsh/_git
  '';

  # Write .zshrc to share/zshrc/zshrc
  zshrc = writeText "zshrc"
    (lib.concatStringsSep "\n"
      ([
        # Set up nix autocomplete
        ''
          fpath+=(${nix}/share/zsh/site-functions)
          fpath+=(${git-completion-zsh}/git-completion.zsh)
        ''
        (builtins.readFile ./zshrc)
        # Set up fzf terminal bindings
        ''
          source ${fzf}/share/fzf/completion.zsh
          source ${./fzf-key-bindings.zsh}
        ''
        # Set up useful env vars (NIX_PATH to have a set nixpkgs)
        ''
          export NIX_PATH=nixpkgs=${nixpkgs-src}
        ''

      ] ++
      # some tools use SSL_CERT_FILE, some others use NIX_SSL_CERT_FILE, some use both. In general, use the system certs as source of truth.
      lib.optional stdenv.hostPlatform.isDarwin ''
        export SSL_CERT_FILE=/etc/ssl/cert.pem
        export NIX_SSL_CERT_FILE=/etc/ssl/cert.pem
      '')
    );
in

runCommand "zshrc" { } ''
  mkdir -p $out/share/zshrc
  cp ${zshrc} $out/share/zshrc/zshrc
''
