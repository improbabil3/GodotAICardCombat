#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 0.1.0"
  exit 1
fi

VERSION="$1"

git add -A
git commit -m "chore(release): $VERSION" || true
git tag -a "v$VERSION" -m "Release $VERSION"
git push origin HEAD
git push origin "v$VERSION"

if command -v gh >/dev/null 2>&1; then
  gh release create "v$VERSION" --title "v$VERSION" --notes-file CHANGELOG.md || true
else
  echo "gh CLI not found; create a release via GitHub web UI or install gh: https://cli.github.com/"
fi
