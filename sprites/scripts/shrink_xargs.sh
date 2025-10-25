#!/bin/bash
set -e

OUTPUT_DIR="thumbnails"
mkdir -p "$OUTPUT_DIR"

NUM_CORES=$(getconf _NPROCESSORS_ONLN)
echo "Running $NUM_CORES in parallel"

ls *.png | xargs -P"$NUM_CORES" -I{} bash -c '
    echo "resizing: {}"
    ffmpeg -hide_banner -loglevel error -nostats \
        -i "{}" \
        -vf scale=iw/4:ih/4:flags=neighbor \
        -compression_level 9 -pix_fmt rgb8 \
        -map_metadata -1 -frames:v 1 "'"$OUTPUT_DIR"'/{}" \
        > /dev/null 2>&1
'

echo "✅ All PNGs resized (pixel-perfect) and saved to '$OUTPUT_DIR/'."
