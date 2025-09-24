#!/usr/bin/env bash
set -euo pipefail
WORK="${1:?work dir required}"
OSX_JAR="${2:?output jar path required}"
[[ "$OSTYPE" == darwin* ]] || { echo "Not macOS; skipping"; exit 0; }
pushd "$WORK" >/dev/null
zip -qr "$OSX_JAR" .
popd >/dev/null
echo "Repacked signed JAR: $OSX_JAR"