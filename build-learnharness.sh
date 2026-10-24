#!/usr/bin/env bash
# Build the LearnHarness server tarball the catalog's `learnharness` entry pins.
#
# Upstream (github.com/amosblomqvist/learnharness, AGPL-3.0) ships desktop
# installers only. This builds its own standalone Next server (the payload its
# Electron app runs) from a release tag, unmodified, and packs it as
# learnharness-<version>-linux-x64.tar.xz with one top folder (strip 1).
#
# Run on Linux x64 (native modules such as resvg are per platform) with Node 26
# (upstream CI's version) and git on PATH, as an ordinary user:
#   bash services/machine-apps/build-learnharness.sh 0.3.5 /tmp/lh-out
# It prints the sha256 and size to pin in catalog.json once the file is
# uploaded to the entry's url.
set -euo pipefail

version="${1:?usage: build-learnharness.sh <version> <out-dir>}"
out="${2:?usage: build-learnharness.sh <version> <out-dir>}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "version must look like 0.3.5" >&2; exit 2; }
[ "$(uname -sm)" = "Linux x86_64" ] || { echo "build on Linux x86_64: native modules are per platform" >&2; exit 2; }
node -e 'process.exit(+process.versions.node.split(".")[0] >= 26 ? 0 : 1)' || { echo "needs Node 26 or newer" >&2; exit 2; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
git -c advice.detachedHead=false clone --quiet --depth 1 --branch "v$version" \
  https://github.com/amosblomqvist/learnharness "$work/src"
cd "$work/src"
echo "source: v$version at $(git rev-parse HEAD)"

npm ci --no-audit --no-fund
NEXT_TELEMETRY_DISABLED=1 npx next build
node scripts/build-server.mjs

top="learnharness-$version"
mv .next/standalone "$work/$top"
# The source offer AGPL asks for travels with the build.
cp LICENSE "$work/$top/LICENSE"
printf 'LearnHarness %s, unmodified.\nSource: https://github.com/amosblomqvist/learnharness/tree/v%s (commit %s)\n' \
  "$version" "$version" "$(git rev-parse HEAD)" > "$work/$top/SOURCE.txt"

mkdir -p "$out"
tarball="$out/$top-linux-x64.tar.xz"
tar -C "$work" --owner=0 --group=0 --numeric-owner --sort=name -cJf "$tarball" "$top"
echo "tarball: $tarball"
echo "sha256:  $(sha256sum "$tarball" | cut -d' ' -f1)"
echo "size:    $(stat -c %s "$tarball")"
