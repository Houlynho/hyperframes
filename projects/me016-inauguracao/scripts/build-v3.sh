#!/usr/bin/env bash
# v3 base montage (63.5s) from the graded mezzanines made by grade-clips.sh.
# Every cut sits on the music grid: drop at 6.8s, one beat = 0.5108s.
# Usage: scripts/build-v3.sh <graded-dir>
set -euo pipefail
G="$1"
OUT="$(cd "$(dirname "$0")/.." && pwd)/assets/v3"
mkdir -p "$OUT"

# video_in video_out clip src_in speed   # what it carries
EDL=(
  "0.000  4.300  BLACK  0    1"      # gag: gas pump + crying wallet (all graphics)
  "4.300  6.800  C028   0.90 1"      # "Calma!" glitch -> sky tilts down to the facade
  "6.800  7.822  C026   1.00 1"      # DROP: facade sign
  "7.822  8.843  C025   0.00 1"      # shop window scooter
  "8.843  9.865  C030   1.20 1"      # facade logo
  "9.865  10.886 C035   2.30 1"      # inside: blue logo wall
  "10.886 11.397 C040   0.00 1"      # "multimarcas" quick montage
  "11.397 11.908 C037   3.00 1"
  "11.908 12.418 C038   0.00 1"
  "12.418 12.930 C029   0.00 1"
  "12.930 14.970 C031   2.60 1"      # ESCOLHA SEU ESTILO: pneu largão
  "14.970 15.990 C033   0.00 1"
  "15.990 16.505 C033   3.20 1"
  "16.505 19.060 C037   0.00 1"      # scooter clássica
  "19.060 20.590 C037   2.60 1"
  "20.590 21.100 C038   1.70 1"      # "E cor?" colour burst
  "21.100 21.610 C040   0.00 1"
  "21.610 22.120 C033   4.60 1"
  "22.120 22.630 C038   3.20 1"
  "22.630 23.140 C031   4.20 1"
  "23.140 25.190 195336 2.00 1"      # panel part 1: press START, lights at 24.14
  "25.190 27.230 195336 9.20 1"      # panel part 2: steady (reflective middle cut)
  "27.230 31.310 195801 0.00 0.86"   # autopropelido plate -> SEM CNH stamps
  "31.310 33.360 C040   1.60 1"      # benefits icons
  "33.360 35.400 C038   0.00 1"
  "35.400 37.440 C037   5.50 1"      # "tão silenciosa..."
  "37.440 41.500 C038   2.20 0.6"    # nosy-neighbour window gag (slow-mo)
  "41.500 46.800 C031   0.00 0.95"   # ex-gas-station notification gag
  "46.800 48.840 C026   0.30 1"      # music back: TEST DRIVE on the facade
  "48.840 50.880 C028   1.45 1"      # address
  "50.880 57.000 C035   0.00 0.5"    # WhatsApp / link na bio / @
  "57.000 63.500 C035   2.10 0.5"    # tagline + logo lockup
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
