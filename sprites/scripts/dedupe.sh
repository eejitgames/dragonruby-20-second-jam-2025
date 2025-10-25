#!/bin/bash
set -euo pipefail

DUP_DIR="duplicates"
mkdir -p "$DUP_DIR"

declare -A seen

echo "🔍 Scanning for duplicates..."

# Loop over all regular files in the current directory
for f in *.png; do
    [ -f "$f" ] || continue  # skip directories or non-files

    # Compute md5sum (hash only)
    hash=$(md5sum "$f" | awk '{print $1}')

    if [[ -n "${seen[$hash]+x}" ]]; then
        echo "🗑️  Duplicate: $f → $DUP_DIR/"
        mv -n -- "$f" "$DUP_DIR/"
    else
        seen["$hash"]="$f"
    fi
done

echo "✅ Done. Duplicates moved to '$DUP_DIR/'."

