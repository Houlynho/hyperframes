#!/usr/bin/env bash
# v3 grade: per-clip white balance measured toward neutral-cool, exposure
# evened out, gentle contrast. Writes graded 1080x1920 30fps mezzanines.
# Usage: scripts/grade-clips.sh <raw-clips-dir> <out-dir>
set -euo pipefail
RAW="$1"
OUT="$2"
mkdir -p "$OUT"

# id | colortemperature (K, ffmpeg: higher = cooler) | brightness offset | extra
# Temperatures come from a per-clip search that drives mean chroma to
# V-U ~ -2 (slightly cool) around 128; brightness evens the means to ~130.
GRADES=(
  "C025   8000  0.02  -"
  "C026   8000  0.08  -"
  "C028   7000  0.06  -"
  "C029  20000  0.04  -"
  "C030   9000  0.03  -"
  "C031  15500  0.02  -"
  "C033  20000  0.07  -"
  "C035   8000  0.06  -"
  "C037  20000  0.00  -"
  "C038  14000 -0.05  hot"
  "C040  14000 -0.04  hot"
  "195336 8500  0.08  -"
  "195801 9000  0.10  -"
)

for row in "${GRADES[@]}"; do
  read -r id temp bright extra <<<"$row"
  src=$(ls "$RAW"/*"$id".mp4 | head -1)
  curve="curves=all='0/0 0.06/0.04 0.5/0.52 0.92/0.94 1/1'"
  # window-blown interiors: pull the top end down so the glass keeps detail
  [ "$extra" = hot ] && curve="curves=all='0/0 0.06/0.04 0.5/0.48 0.8/0.76 1/0.94'"
  vf="scale=1080:1920:flags=lanczos,setsar=1,colortemperature=temperature=${temp}:mix=1:pl=1,eq=contrast=1.06:brightness=${bright}:saturation=1.12,${curve},unsharp=5:5:0.45,fps=30,format=yuv420p"
  ffmpeg -v error -y -i "$src" -vf "$vf" -an -c:v libx264 -preset medium -crf 14 "$OUT/$id.mp4"
  echo "graded $id"
done
