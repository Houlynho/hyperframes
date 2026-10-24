#!/usr/bin/env bash
# 20s ad base montage from the graded mezzanines made by grade-clips.sh.
# Every cut sits on the music grid: track drop at video 0.0s, one beat = 0.5108s.
# Usage: scripts/build-v3.sh <graded-dir>
set -euo pipefail
G="$1"
OUT="$(cd "$(dirname "$0")/.." && pwd)/assets/ad20"
mkdir -p "$OUT"

# video_in video_out clip src_in speed   # what it carries
EDL=(
  "0.000  2.043  195336 2.00 1"      # HOOK: press START, panel lights at 1.0s
  "2.043  4.597  195801 0.20 1"      # proof: autopropelido plate + stamps
  "4.597  5.108  C040   0.00 1"      # model montage on the beat
  "5.108  5.619  C037   2.60 1"
  "5.619  6.130  C031   2.60 1"
  "6.130  6.640  C038   1.70 1"
  "6.640  7.151  C033   3.20 1"
  "7.151  7.662  C037   0.00 1"
  "7.662  8.173  C029   0.00 1"
  "8.173  8.682  C038   3.20 1"
  "8.682  11.746 C031   0.00 1"      # ex-gas-station notification gag
  "11.746 12.768 C026   1.00 1"      # "Mi Zero Dezesseis" facade sign
  "12.768 13.789 C030   1.20 1"
  "13.789 14.810 C025   0.00 1"      # TEST DRIVE
  "14.810 16.854 C028   1.45 1"      # address
  "16.854 20.000 C035   2.20 0.5"    # WhatsApp end card
)

inputs=()
filters=""
labels=""
i=0
for row in "${EDL[@]}"; do
  read -r t0 t1 id src speed <<<"$row"
  frames=$(awk -v a="$t0" -v b="$t1" 'BEGIN{printf "%d", int(b*30+0.5)-int(a*30+0.5)}')
  if [ "$id" = BLACK ]; then
    inputs+=(-f lavfi -t "$(awk -v f="$frames" 'BEGIN{printf "%.3f", f/30+0.1}')" -i "color=c=0x0b1230:s=1080x1920:r=30")
    filters+="[$i:v]trim=end_frame=${frames},setpts=PTS-STARTPTS,format=yuv420p[v$i];"
  else
    need=$(awk -v f="$frames" -v s="$speed" 'BEGIN{printf "%.3f", f/30*s+0.15}')
    inputs+=(-ss "$src" -t "$need" -i "$G/$id.mp4")
    pts=$(awk -v s="$speed" 'BEGIN{printf "%.4f", 1/s}')
    filters+="[$i:v]setpts=${pts}*(PTS-STARTPTS),fps=30,trim=end_frame=${frames},setpts=PTS-STARTPTS,format=yuv420p[v$i];"
  fi
  labels+="[v$i]"
  i=$((i + 1))
done
filters+="${labels}concat=n=${i}:v=1:a=0[out]"

ffmpeg -v error -y "${inputs[@]}" -filter_complex "$filters" -map "[out]" \
  -c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p -r 30 -movflags +faststart "$OUT/base.mp4"
ffprobe -v error -count_frames -show_entries stream=nb_read_frames -of csv=p=0 "$OUT/base.mp4"
