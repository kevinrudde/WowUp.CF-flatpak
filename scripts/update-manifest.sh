#!/usr/bin/env bash
# Usage: update-manifest.sh <stable|beta> <manifest>
# Points the manifest at the newest matching WowUp.CF release.
# stable: newest non-prerelease. beta: newest release of any kind.
# Prints "version=<tag>" to $GITHUB_OUTPUT when the manifest changed.
set -euo pipefail

channel=$1
manifest=$2

case "$channel" in
  stable) filter='map(select(.draft | not) | select(.prerelease | not))' ;;
  beta)   filter='map(select(.draft | not))' ;;
  *) echo "unknown channel: $channel" >&2; exit 1 ;;
esac

release=$(gh api repos/WowUp/WowUp.CF/releases --jq "$filter | first")
tag=$(jq -r '.tag_name' <<< "$release")
asset=$(jq -c '.assets[] | select(.name | endswith(".AppImage"))' <<< "$release")
url=$(jq -r '.browser_download_url' <<< "$asset")
digest=$(jq -r '.digest' <<< "$asset")

if [[ -z "$tag" || "$tag" == null || -z "$url" || "$digest" != sha256:* ]]; then
  echo "no usable AppImage asset with sha256 digest found for channel $channel" >&2
  exit 1
fi

sha256=${digest#sha256:}

if grep -qF "sha256: $sha256" "$manifest"; then
  echo "$manifest already up to date ($tag)"
  exit 0
fi

sed -i -e "s|^\( *url: \)https://github.com/WowUp/.*\.AppImage$|\1$url|" \
       -e "s|^\( *sha256: \).*|\1$sha256|" "$manifest"

echo "version=$tag" >> "${GITHUB_OUTPUT:-/dev/stdout}"
