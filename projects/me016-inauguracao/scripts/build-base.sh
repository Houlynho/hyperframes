#!/usr/bin/env bash
# Builds the graded, beat-cut 9:16 base montage + trimmed music bed.
# Usage: scripts/build-base.sh <raw-clips-dir> <music.wav>
# Raw clips are the iPhone HEVC files named *A001_<date>_C0NN.mp4.
set -euo pipefail

RAW="$1"
MUSIC="$2"
OUT="$(cd "$(dirname "$0")/.." && pwd)/assets"
mkdir -p "$OUT"

# --- Color grades ---------------------------------------------------------
# Interior: pull the warm floor/light cast toward neutral, firm the blacks, add pop.
INT="colorbalance=rs=-0.03:gs=-0.01:bs=0.05:rm=-0.07:gm=-0.01:bm=0.07:rh=-0.03:bh=0.04,eq=contrast=1.12:brightness=-0.015:saturation=1.25:gamma=0.98,curves=all='0/0 0.08/0.035 0.5/0.5 0.93/0.95 1/1'"
# Exterior: flat daylight -> more contrast, bluer sky, livelier color.
EXT="eq=contrast=1.14:brightness=-0.01:saturation=1.3:gamma=0.95,colorbalance=bs=0.03:bm=0.02:rm=-0.01,curves=all='0/0 0.1/0.06 0.5/0.5 0.9/0.93 1/1'"
# Dark facade wall: contrast only, keep the gray neutral.
WALL="eq=contrast=1.14:brightness=-0.01:saturation=1.05:gamma=0.95,curves=all='0/0 0.1/0.06 0.5/0.5 0.9/0.93 1/1'"
# Window-blown interiors: same neutralising as INT plus highlight recovery.
HOT="colorbalance=rs=-0.03:bs=0.05:rm=-0.07:bm=0.07:rh=-0.03:bh=0.04,eq=contrast=1.08:brightness=-0.03:saturation=1.28:gamma=0.90,curves=all='0/0 0.1/0.05 0.5/0.46 0.85/0.84 1/0.98'"

# --- Edit decision list ---------------------------------------------------
# clip | grade | source in (s) | output frames @30fps | speed (1 = realtime)
# Music bed starts at track 4.0s, so the drop lands at video 2.0s and every
# cut sits on the 120 BPM grid (0.5s = 15 frames).
EDL=(
  "C026 EXT  0.60 60  1"     # 0.0-2.0  facade sign pan (riser + INAUGUROU)
  "C025 EXT  0.00 30  1"     # 2.0-3.0  DROP: scooter in the shop window
  "C030 WALL 1.20 30  1"     # 3.0-4.0  logo on the facade
  "C029 INT  0.00 30  1"     # 4.0-5.0  white chopper + balloons
  "C031 INT  2.80 30  1"     # 5.0-6.0  chopper front
  "C033 INT  0.00 30  1"     # 6.0-7.0  chopper headlight
  "C033 INT  3.00 30  1"     # 7.0-8.0  red chopper
  "C033 INT  4.60 30  1"     # 8.0-9.0  UK-flag chopper
  "C037 INT  0.00 45  1"     # 9.0-10.5 light-blue scooter
  "C037 INT  2.80 45  1"     # 10.5-12  green scooter
  "C038 HOT  0.00 30  1"     # 12-13    black scooter + banner
  "C038 HOT  1.70 30  1"     # 13-14    red scooter
  "C040 HOT  0.00 30  1"     # 14-15    chopper row + banner
  "C040 HOT  1.60 30  1"     # 15-16    chopper under the logo
  "C035 INT  2.30 240 0.40"  # 16-24    blue logo wall, centred, slow-mo (end card)
)

inputs=()
filters=""
labels=""
i=0
for row in "${EDL[@]}"; do
  read -r id grade start frames speed <<<"$row"
  src=$(ls "$RAW"/*"$id".mp4 | head -1)
  # seconds of source needed for this many output frames at this speed (+pad)
  need=$(awk -v f="$frames" -v s="$speed" 'BEGIN{printf "%.3f", f/30*s+0.2}')
  inputs+=(-ss "$start" -t "$need" -i "$src")
  g="${!grade}"
  pts=$(awk -v s="$speed" 'BEGIN{printf "%.4f", 1/s}')
  filters+="[$i:v]setpts=${pts}*(PTS-STARTPTS),scale=1080:1920:flags=lanczos,setsar=1,${g},unsharp=5:5:0.5,fps=30,trim=end_frame=${frames},setpts=PTS-STARTPTS,format=yuv420p[v$i];"
  labels+="[v$i]"
  i=$((i + 1))
done
filters+="${labels}concat=n=${i}:v=1:a=0[out]"

ffmpeg -v error -y "${inputs[@]}" -filter_complex "$filters" -map "[out]" \
  -c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p -r 30 -movflags +faststart \
  "$OUT/base.mp4"

# Music bed: 24s from track 4.0s, loudness-normalised for social, tail fade.
ffmpeg -v error -y -ss 4.0 -t 24 -i "$MUSIC" \
  -af "loudnorm=I=-14:TP=-1.0:LRA=9,afade=t=out:st=22.2:d=1.8" \
  -ar 48000 -c:a pcm_s16le "$OUT/music.wav"

ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/base.mp4"
