#!/bin/bash
set -e

OUTPUT_DIR="transparent"
mkdir -p "$OUTPUT_DIR"

NUM_CORES=$(getconf _NPROCESSORS_ONLN)
echo "Running $NUM_CORES in parallel"

ls *.png | xargs -P"$NUM_CORES" -I{} bash -c '
    echo "make black transparent: {}"
    ffmpeg -hide_banner -loglevel error -nostats \
        -i "{}" \
        -vf "colorkey=0x000000:0.01:0.0" \
        -c:v png "'"$OUTPUT_DIR"'/{}" \
        > /dev/null 2>&1
'

echo "✅ All PNGs black removed/made transparent and saved to '$OUTPUT_DIR/'."
