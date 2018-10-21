# TODO: document
package:
  let
    versions = builtins.fromJSON (builtins.readFile ./versions.json);
    spec = versions.${package};
    fetchTarball =
      # fetchTarball version that is compatible between all the versions of
      # Nix
      { url, sha256 }@attrs:
      let
        inherit (builtins) lessThan nixVersion fetchTarball;
      in
        if lessThan nixVersion "1.12" then
          fetchTarball { inherit url; }
        else
          fetchTarball attrs;
  in
    fetchTarball {
      url =
        with spec;
        "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = spec.sha256;
    }
