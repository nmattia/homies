#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq
#
# Updates the *.src.json to the latest commit
set -euo pipefail

usage() {
  echo "Usage: $0 <src-json>" >&2
  exit 1
}

source=${1:-}

if [[ -z $source ]]; then
  echo "source argument missing" >&2
  exit 1
fi

# Heuristic
if [[ ! $source =~ \.src\.json$ ]]; then
  if [[ -d $source ]]; then
    source=$source/default.src.json
  elif [[ -f $source ]]; then
    source="${source%.*}.json"
  fi
fi

if ! [[ -f $source ]]; then
  echo "source file $source missing" >&2
  exit 1
fi

echo "updating $source..."

owner=$(jq -er '.owner' < "$source")
repo=$(jq -er '.repo' < "$source")
branch=$(jq -er '.branch // ""' < "$source")

if [[ -n $branch ]]; then
  rev=$(curl -sfL https://api.github.com/repos/$owner/$repo/git/refs/heads/$branch | jq -r .object.sha)
else
  rev=$(jq -er '.rev' < "$source")
fi

url=https://github.com/$owner/$repo/archive/$rev.tar.gz

echo "fetching $url..."

# don't unpack for the bootstrap version
release_sha256=$(nix-prefetch-url --unpack "$url")

cat <<NEW_SOURCE | tee "$source"
{
  "owner": "$owner",
  "repo": "$repo",
  "branch": "$branch",
  "rev": "$rev",
  "sha256": "$release_sha256"
}
NEW_SOURCE
