#!/usr/bin/env bash
set -euo pipefail
OSX_JAR="${1:?osx jar path required}"
WORK="${2:?work dir required}"
[[ "$OSTYPE" == darwin* ]] || { echo "Not macOS; skipping"; exit 0; }
[[ -f "$OSX_JAR" ]] || { echo "Missing $OSX_JAR"; exit 1; }
rm -rf "$WORK"
mkdir -p "$WORK"
unzip -q "$OSX_JAR" -d "$WORK"
echo "Exploded $OSX_JAR into $WORK"
