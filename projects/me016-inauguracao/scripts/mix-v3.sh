#!/usr/bin/env bash
# v3 audio: VO phrases placed on the edit, music bed offset so its drop hits
# the facade reveal (6.8s), ducked under the voice, plus SFX. 63.5s, -14 LUFS.
# Usage: scripts/mix-v3.sh <vo.mp3> <music.wav> <sfx-dir>
set -euo pipefail
VO="$1"
MUSIC="$2"
SFX="$3"
OUT="$(cd "$(dirname "$0")/.." && pwd)/assets/v3"
mkdir -p "$OUT"
DUR=63.5
MUSIC_OFFSET=1.78 # music drop (8.58s) -> video 6.8s

# vo_in vo_out video_at   # line (windows aligned by DTW + snapped to pauses)
PHRASES=(
  "0.000  1.135  0.30"    # Abasteceu de novo?
  "2.283  2.961  1.90"    # E a carteira?
  "4.029  4.533  3.15"    # Chorando.
  "5.252  5.957  4.35"    # Calma!
  "6.729  8.193  5.30"    # A solução acabou de chegar.
  "8.703  12.259 7.20"    # Inaugurou a Mi Zero Dezesseis Mobilidade Elétrica!
  "12.626 14.836 11.00"   # Multimarcas, com modelo pra todo estilo.
  "15.489 17.904 13.60"   # Curte chamar atenção? Vai de pneu largão.
  "18.632 22.298 16.60"   # Prefere algo clássico? A scooter é elegante…
  "22.879 24.669 20.40"   # E cor? Tem pra todo gosto.
  "25.254 27.371 22.34"   # Aperta o botão... e pronto!  ("pronto" = panel on, 24.14)
  "27.923 29.625 25.30"   # Liga na hora, sem barulho nenhum.
  "30.046 33.457 27.50"   # E o melhor: não precisa de CNH, nem de emplacamento!
  "34.052 38.102 31.60"   # Não usa gasolina, carrega na tomada, manutenção…
  "38.614 40.261 35.80"   # E é tão silenciosa...
  "40.525 42.937 38.60"   # que nem o vizinho fofoqueiro percebe você saindo.
  "44.020 44.621 41.90"   # E o posto?
  "45.413 46.661 43.15"   # Vai sentir sua falta.
  "47.042 47.816 45.30"   # Deixa no vácuo!
  "48.363 49.790 46.90"   # Vem fazer seu test drive!
  "50.190 52.628 48.60"   # Avenida Luzitana, 552.
  "53.010 57.593 52.87"   # Ou chama no WhatsApp: o link tá na bio do @…
  "58.540 59.748 57.90"   # Mi Zero Dezesseis:
  "60.013 60.804 59.35"   # o futuro chegou...
  "61.317 62.800 60.50"   # e ele não bebe gasolina!
)

# file video_at gain_dB [max_len]
SFXS=(
  "pop.mp3            0.20  -6"
  "typing.mp3         0.55  -9"
  "pop.mp3            1.85  -6"
  "error.mp3          3.15  -7"
  "glitch-2.mp3       4.30  -9  0.7"
  "whoosh.mp3         6.55  -8"
  "impact-bass-1.mp3  6.80  -4"
  "whoosh-short.mp3   7.82  -13"
  "whoosh-short.mp3   8.84  -13"
  "sparkle.mp3        9.87  -9"
  "whoosh.mp3         10.89 -11"
  "sparkle.mp3        12.93 -9"
  "pop.mp3            13.15 -8"
  "pop.mp3            16.70 -8"
  "pop.mp3            20.59 -10"
  "pop.mp3            21.10 -10"
  "pop.mp3            21.61 -10"
  "pop.mp3            22.12 -10"
  "click.mp3          23.62 -3"
  "chime.mp3          24.14 -8"
  "impact-bass-2.mp3  29.05 -5"
  "impact-bass-2.mp3  30.30 -5"
  "pop.mp3            31.70 -8"
  "pop.mp3            32.95 -8"
  "pop.mp3            34.10 -8"
  "key-press.mp3      39.20 -8"
  "notification.mp3   42.55 -4"
  "click-soft.mp3     44.75 -4"
  "whoosh.mp3         46.60 -8"
  "impact-bass-1.mp3  46.80 -5"
  "whoosh-short.mp3   48.84 -12"
  "whoosh-short.mp3   50.88 -12"
  "ping.mp3           53.30 -9"
  "sparkle.mp3        57.00 -9"
  "impact-bass-2.mp3  62.36 -6"
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
f+="volume=enable='between(t,3.10,4.30)':volume=0[mus];"
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
