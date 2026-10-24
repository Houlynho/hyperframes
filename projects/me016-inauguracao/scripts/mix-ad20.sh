#!/usr/bin/env bash
# 20s ad audio: phrases re-cut from the v3 VO take, music starting on its drop,
# ducked under the voice, plus SFX. 20s, -14 LUFS.
# Usage: scripts/mix-v3.sh <vo.mp3> <music.wav> <sfx-dir>
set -euo pipefail
VO="$1"
MUSIC="$2"
SFX="$3"
OUT="$(cd "$(dirname "$0")/.." && pwd)/assets/ad20"
mkdir -p "$OUT"
DUR=20
MUSIC_OFFSET=8.58 # music drop -> first frame

# vo_in vo_out video_at   # line (windows aligned by DTW + snapped to pauses)
PHRASES=(
  "30.930 32.270 0.15"    # não precisa de CNH,
  "32.434 33.353 1.60"    # nem de emplacamento!
  "34.052 38.102 2.85"    # Não usa gasolina, carrega na tomada, manutenção…
  "22.879 24.669 6.92"    # E cor? Tem pra todo gosto.
  "44.020 44.621 8.85"    # E o posto?
  "45.413 46.661 9.60"    # Vai sentir sua falta.
  "47.042 47.816 11.00"   # Deixa no vácuo!
  "58.540 59.748 11.95"   # Mi Zero Dezesseis:
  "48.363 49.790 13.30"   # Vem fazer seu test drive!
  "50.190 52.628 14.95"   # Avenida Luzitana, 552.
  "53.010 53.844 17.55"   # Ou chama no WhatsApp!
)

# file video_at gain_dB [max_len]
SFXS=(
  "click.mp3          0.50  -3"
  "impact-bass-1.mp3  1.00  -5"
  "chime.mp3          1.00  -10"
  "impact-bass-2.mp3  2.10  -8"
  "impact-bass-2.mp3  2.65  -8"
  "impact-bass-2.mp3  3.20  -8"
  "pop.mp3            4.60  -8"
  "pop.mp3            5.62  -8"
  "pop.mp3            7.15  -10"
  "pop.mp3            7.66  -10"
  "pop.mp3            8.17  -10"
  "notification.mp3   8.85  -4"
  "notification.mp3   9.90  -9"
  "click-soft.mp3     10.60 -4"
  "whoosh.mp3         11.60 -9"
  "sparkle.mp3        11.80 -10"
  "impact-bass-1.mp3  13.79 -6"
  "whoosh-short.mp3   14.81 -12"
  "pop.mp3            14.95 -7"
  "whoosh.mp3         16.75 -9"
  "ping.mp3           17.85 -9"
  "impact-bass-2.mp3  19.41 -7"
)

inputs=(-i "$VO" -i "$MUSIC")
f=""
# --- voice bus
f+="[0:a]aresample=48000,highpass=f=90,acompressor=threshold=-20dB:ratio=3:attack=5:release=80:makeup=3dB,asplit=${#PHRASES[@]}"
for i in "${!PHRASES[@]}"; do f+="[p$i]"; done
f+=";"
vmix=""
for i in "${!PHRASES[@]}"; do
  read -r a b at <<<"${PHRASES[$i]}"
  ms=$(awk -v t="$at" 'BEGIN{printf "%d", t*1000}')
  fo=$(awk -v a="$a" -v b="$b" 'BEGIN{printf "%.3f", b-a-0.04}')
  f+="[p$i]atrim=start=$a:end=$b,asetpts=PTS-STARTPTS,afade=t=in:d=0.02,afade=t=out:st=$fo:d=0.04,adelay=${ms}|${ms}[d$i];"
  vmix+="[d$i]"
done
f+="${vmix}amix=inputs=${#PHRASES[@]}:normalize=0,apad=whole_dur=$DUR,atrim=0:$DUR,asplit[voice][key];"
# --- music: offset, hard stop on "Chorando" (3.10-4.30), ducked by the voice
f+="[1:a]aresample=48000,atrim=start=$MUSIC_OFFSET,asetpts=PTS-STARTPTS,apad=whole_dur=$DUR,atrim=0:$DUR,volume=-4dB,"
f+="afade=t=out:st=19.4:d=0.6[mus];"
f+="[mus][key]sidechaincompress=threshold=0.03:ratio=7:attack=15:release=350:makeup=1[ducked];"
# --- SFX bus
smix=""
n=2
for i in "${!SFXS[@]}"; do
  read -r file at gain maxlen <<<"${SFXS[$i]}"
  inputs+=(-i "$SFX/$file")
  ms=$(awk -v t="$at" 'BEGIN{printf "%d", t*1000}')
  trim=""
  [ -n "${maxlen:-}" ] && trim="atrim=0:$maxlen,afade=t=out:st=$(awk -v m="$maxlen" 'BEGIN{printf "%.2f", m-0.2}'):d=0.2,"
  f+="[$n:a]aresample=48000,aformat=channel_layouts=stereo,${trim}volume=${gain}dB,adelay=${ms}|${ms}[s$i];"
  smix+="[s$i]"
  n=$((n + 1))
done
f+="${smix}amix=inputs=${#SFXS[@]}:normalize=0,apad=whole_dur=$DUR,atrim=0:$DUR[sfx];"
# --- master
f+="[ducked][voice][sfx]amix=inputs=3:normalize=0,loudnorm=I=-14:TP=-1.0:LRA=9,aresample=48000[out]"

ffmpeg -v error -y "${inputs[@]}" -filter_complex "$f" -map "[out]" -t "$DUR" \
  -ar 48000 -ac 2 -c:a pcm_s16le "$OUT/mix.tmp.wav"
ffmpeg -v error -y -i "$OUT/mix.tmp.wav" -af apad -t "$DUR" -c:a pcm_s16le "$OUT/mix.wav"
rm -f "$OUT/mix.tmp.wav"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/mix.wav"
