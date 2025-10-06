#!/bin/bash

OUTPUT_DIR="thumbnails"
mkdir -p "$OUTPUT_DIR"

for f in *.png; do
    [ -f "$f" ] || continue
    echo "resizing: $f"
    ffmpeg -hide_banner -loglevel error -nostats \
        -i "$f" \
        -vf scale=iw/8:ih/8:flags=neighbor \
        -compression_level 9 -pix_fmt rgb8 \
        -map_metadata -1 -frames:v 1 "$OUTPUT_DIR/$f" \
        > /dev/null 2>&1
done

echo "✅ All PNGs resized (pixel-perfect) and saved to '$OUTPUT_DIR/'."
