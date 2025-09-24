#!/usr/bin/env bash
set -euo pipefail

WORK="${1:?work dir required}"
IDENTITY="${2:-${MAC_SIGN_IDENTITY:-}}"
if [[ -z "${IDENTITY}" ]]; then
  echo "Set MAC_SIGN_IDENTITY env or pass identity as arg2"; exit 64
fi

case "${OSTYPE-}" in darwin*) ;; *) echo "Not macOS; skipping"; exit 0;; esac

# Collect list first (avoids subshell flag issues)
list="$(find "$WORK" -type f \( -name '*.jnilib' -o -name '*.dylib' \))"
if [[ -z "$list" ]]; then
  echo "No native libs found under $WORK"
  exit 0
fi

while IFS= read -r n; do
  [[ -n "$n" ]] || continue
  echo "Signing $n"
  codesign --force --options runtime --timestamp --sign "$IDENTITY" "$n"

  echo "Verify codesign (verbose):"
  codesign --verify --verbose=4 "$n" || { echo "Verify failed: $n"; exit 65; }

  echo "Display embedded signature details:"
  codesign -dvvv "$n" 2>&1 | sed 's/^/  /'

  echo "Check Mach-O code signature load command (AAPL,code-signature):"
  if command -v otool >/dev/null 2>&1; then
    otool -l "$n" | awk '
      $1=="Load" && $2=="command" {in_lc=0}
      $1=="cmd" && $2=="LC_CODE_SIGNATURE" {in_lc=1; print "  LC_CODE_SIGNATURE found"}
      in_lc && $1=="dataoff" {print "  " $0}
      in_lc && $1=="datasize" {print "  " $0}
    '
  else
    echo "  otool not available; skipping Mach-O load check"
  fi

  echo ""
done <<< "$list"

echo "Signed and inspected $(echo "$list" | wc -l | tr -d ' ') native library(ies)"