#!/usr/bin/env bash
# Places the voiceover phrases on the video timeline and ducks the music under them.
# Usage: scripts/mix-voiceover.sh <voiceover.mp3>
# Needs assets/music.wav from build-base.sh. Writes assets/mix.wav (24s, -14 LUFS).
set -euo pipefail

VO="$1"
ASSETS="$(cd "$(dirname "$0")/.." && pwd)/assets"

# Phrase windows in the VO take (seconds, aligned by DTW against an espeak
# reference and snapped to the take's own pauses) -> where each lands in the video.
# vo_start vo_end video_at   # line
PHRASES=(
  "0.21  2.73  0.05"   # A Mi Zero Dezesseis inaugurou!            (hook card)
  "2.82  6.08  2.60"   # Motos elétricas multimarcas, econômicas…  (cards 2-3)
  "6.18  7.94  6.30"   # Diga adeus à gasolina!                    (card 4)
  "8.07  10.66 9.10"   # Vários modelos e cores pra você escolher. (card 5)
  "10.80 12.43 12.20"  # Vem conhecer a nossa loja!                (card 6)
  "12.54 18.20 17.60"  # Chama no WhatsApp… Avenida Luzitana, 552. (end card)
)

filters="[0:a]aresample=48000,highpass=f=90,acompressor=threshold=-20dB:ratio=3:attack=5:release=80:makeup=3dB,asplit=${#PHRASES[@]}"
for i in "${!PHRASES[@]}"; do filters+="[p$i]"; done
filters+=";"
mixin=""
for i in "${!PHRASES[@]}"; do
  read -r a b at <<<"${PHRASES[$i]}"
  ms=$(awk -v t="$at" 'BEGIN{printf "%d", t*1000}')
  filters+="[p$i]atrim=start=$a:end=$b,asetpts=PTS-STARTPTS,afade=t=in:d=0.02,afade=t=out:st=$(awk -v a="$a" -v b="$b" 'BEGIN{printf "%.3f", b-a-0.04}'):d=0.04,adelay=${ms}|${ms}[d$i];"
  mixin+="[d$i]"
done
# voice bus, padded to 24s
filters+="${mixin}amix=inputs=${#PHRASES[@]}:normalize=0,apad=whole_dur=24,atrim=0:24,asplit[voice][key];"
# music ducked by the voice (sidechain), then summed and normalised
filters+="[1:a]aresample=48000,volume=-3dB[mus];"
filters+="[mus][key]sidechaincompress=threshold=0.03:ratio=8:attack=15:release=350:makeup=1[ducked];"
filters+="[ducked][voice]amix=inputs=2:normalize=0,loudnorm=I=-14:TP=-1.0:LRA=9,aresample=48000,apad[out]"

ffmpeg -v error -y -i "$VO" -i "$ASSETS/music.wav" -filter_complex "$filters" -map "[out]" -t 24 \
  -ar 48000 -ac 2 -c:a pcm_s16le "$ASSETS/mix.tmp.wav"
# loudnorm's look-ahead eats a few ms at the tail; pad back to exactly 24s
ffmpeg -v error -y -i "$ASSETS/mix.tmp.wav" -af apad -t 24 -c:a pcm_s16le "$ASSETS/mix.wav"
rm -f "$ASSETS/mix.tmp.wav"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$ASSETS/mix.wav"
