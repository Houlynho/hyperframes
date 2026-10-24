---
name: paper-bench-explainer
description: "Visual style for explanatory / demonstrative vertical videos (9:16 Reels / Shorts / TikTok): a green cutting-mat workbench background, crumpled paper notes taped to it with handwritten step titles and a yellow highlighter stroke, dark rounded data cards (capacity bars, typewriter terminals, gauges, node flowcharts), and a retro pixel-art cursor whose clicks ignite every transition. Constant micro-motion (something new every 1-2s) plus a dense SFX bed (pop, whoosh, click, pen scribble, paper crumple) under clean narration and quiet lo-fi. Load when the user asks for a video that is 'bem explicativo', 'demonstrativo', didactic, a tutorial, a step-by-step, a how-it-works, or an edu-tech explainer, and when they ask for 'aquele estilo do papel / da base verde'. [explainer, tutorial, step-by-step, didactic, edu-tech, paper, cutting-mat, handwritten, infographic, data-card, terminal, gauge, flowchart, pixel-cursor, sfx, vertical, reels]"
metadata:
  internal: true
---

# Paper Bench Explainer: the workbench style

Learned from a reference reel the user liked (an edu-tech video explaining how to run
local AI on an old PC, 9:16, ~2:12). The look reads as a **maker's bench**: real-world
craft textures (cutting mat, paper, tape, pen) host crisp digital UI cards. That
contrast between analog and digital is the whole identity. Keep it.

This is a **style layer**, not a workflow. Route the job through the normal workflow
(`/faceless-explainer` for no-footage explainers, `/general-video` when the user
supplies a talking-head hook or B-roll) and apply this skill's tokens, components and
beat grammar on top. Motion law still comes from `motion-doctrine` / `cut-the-curve`.
The cursor technique comes from `oversized-cursor`; this style only swaps the skin.

## 1. When to propose it (and when not)

Propose it by default when the user asks for a video that should **explain or
demonstrate** something step by step: how something works, a setup, a comparison, a
process with numbered steps, numbers that need a visual analogy.

Do not force it on brand launches, emotional/cinematic pieces, or music-driven edits.
Before building, ask two things: is there a hook clip of the user on camera, and does
the user want the reference's green bench or a palette variation in their own
identity? Cloning the reference 1:1 makes the video read as _that_ creator's.
Default to keeping the grammar and changing the base color and accent (see §2
variants).

## 2. Design tokens

```css
:root {
  /* bench */
  --mat: #2f7d4f; /* cutting-mat green */
  --mat-line: rgba(255, 255, 255, 0.28); /* 1px grid every 40px, 2px every 200px */
  --mat-ruler: rgba(255, 255, 255, 0.55); /* edge rulers + 30/45/60° guides */
  /* paper */
  --paper: #f6f4ee;
  --paper-shadow: 0 18px 40px rgba(0, 0, 0, 0.28);
  --tape: rgba(235, 222, 180, 0.85); /* masking tape, slight transparency */
  --ink: #1b1b1b;
  --highlight: #ffe45c; /* highlighter stroke behind words */
  /* cards */
  --card: #1a1a24;
  --card-line: rgba(255, 255, 255, 0.08);
  --card-radius: 22px;
  --text-on-card: #f2f2f5;
  /* accents */
  --ok: #4fd38a;
  --warn: #f5c842;
  --bad: #ff5a5a;
  --info: #6ab8ff;
}
```

Variants that keep the identity but avoid looking like a copy. Change only `--mat`
and `--highlight`. Navy bench `#1f3b63` + `#ffd34d`. Terracotta `#b5523b` + `#ffe9a8`.
Graphite `#2b2d31` + `#c6ff4d`.

Typography, three roles, never more:

- **Handwritten**, for step titles on paper ("1 – limpar o pc"). Use Caveat or Kalam
  (Google Fonts, embed locally). Use a size around 120-160px in a 1080-wide frame.
- **Geometric sans bold**, for card titles, labels and captions. Use Inter, Manrope or
  Plus Jakarta at 700-800.
- **Monospace**, for numbers, bits, tokens and terminal text. Use JetBrains Mono or
  IBM Plex Mono.

## 3. Component kit

Build these once per project as sub-compositions or snippets. Check
`/hyperframes-registry` first in case a block already covers one.

1. **Bench background.** A full-frame mat with a CSS grid (`background-image` with
   two repeating-linear-gradients), rulers along two edges and one faint angle guide.
   It is static. The bench never moves. The _camera_ moves over it with slow
   push-ins (scale 1.00 → 1.04 over a scene).
2. **Paper note (chapter card).** A white sheet slightly rotated (−3° to 3°), with an
   SVG crumple texture (a feTurbulence displacement or a baked PNG), two tape strips
   on the corners, a handwritten title, a highlighter swipe and a hand-drawn
   doodle/icon. Entry: it drops in from above with a small overshoot and settles.
   Then the title writes on (a stroke-dashoffset or clip-path wipe, 0.6-0.9s), then
   the highlighter swipes left → right (0.35s, power2.out).
3. **Data card.** A `--card` rounded box with a label, a value in mono and an
   optional capacity bar. Entry: pop-in from scale .9 → 1 with `back.out(1.6)`,
   0.35s, and opacity 0 → 1. Several cards cascade at 0.08-0.12s stagger (waterfall
   entry, `cut-the-curve` §6).
4. **Capacity bar.** The fill animates 0 → value over 0.6-0.9s, `power3.out`. Colour
   encodes the verdict: `--bad` when it "doesn't fit", `--warn` for borderline,
   `--ok` when it fits. The label flips at the end of the fill, never before.
5. **Terminal / chat window.** A dark card with three dots, mono text and a typewriter
   at ~30-40 chars/s with a blinking block caret. Two terminals side by side make a
   speed comparison; the slow one types visibly slower.
6. **Stamp.** A rubber-stamp label ("NÃO É OBRIGATÓRIA", "R$ 10.000+") that slams in
   from scale 1.6 → 1, rotated −8°, with a 2-frame shake and a thud SFX.
7. **Gauge.** A semicircle tachometer whose needle sweeps to a value (`power2.inOut`,
   0.8s), then trembles ±1° for 0.3s on the overload case only.
8. **Tier cards.** A row or stack of options (1B / 3B / 7B / 13B) each with a verdict
   chip ("Voa", "Bom", "No limite", "Travou") coloured ok → warn → bad.
9. **Node flowchart.** A vertical tree of icon nodes linked by dashed connectors. The
   connectors draw (dashoffset) top → bottom, and each node pops as its line arrives.
   A final checklist ticks items one by one in `--ok`.
10. **Benefit stack (outro).** Exactly three cards with an icon and a short line
    each, cascading in. Then hold for 1s.
11. **Pixel cursor.** A classic 90s black-and-white arrow in pixel art (an SVG of
    crisp rects, `image-rendering: pixelated` if it is a PNG). It follows every law in
    `oversized-cursor` (oversized, enters from off-screen, tip-targeting, click tap,
    click-ignites-the-next-beat). Only the skin changes.

## 4. Beat grammar: the rhythm that makes it work

- **Nothing sits still for more than ~1.5s.** Each beat adds _one_ new event: a card
  pops, a bar fills, a word gets highlighted, the cursor clicks. If a narration line is
  long, split its visual into 2-3 sub-events rather than one big entrance.
- **The cursor causes the transitions.** A scene ends with the cursor travelling to
  an element and clicking it. The click is the cut point: zoom-through into the next
  paper note, or a zoom-out from a clicked square button (`cut-the-curve` seams).
- **Analogies over numbers.** Every abstract number gets a visual: RAM becomes a bar
  that does or doesn't fit, compression becomes a big image shrinking 4×, speed
  becomes a gauge, a system becomes a node tree.
- **Paper for chapters, cards for content.** Paper notes only open steps ("1 –", "2 –").
  All explanatory content lives on dark cards. Don't mix them.

## 5. Structure template

| Segment   | Time (60s cut) | Content                                                                                                                                                             |
| --------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hook      | 0-6s           | Talking head holding the real object, or a bold paper note with the question if there is no footage. Caption with highlighted keyword + doodle. Cursor click exits. |
| Step 1..N | 6-50s          | Per step: paper note (2-3s), then 3-6 card beats. B-roll top-down shots slot in here when available.                                                                |
| Outro     | 50-60s         | Three-card benefit stack, then a CTA line.                                                                                                                          |

The reference ran 2:12. Recommend **45-75s with 3 steps** for Reels unless the topic
has proven search demand. Offer the rest as a part 2.

## 6. Sound design map

Narration is the spine: clean voiceover, no room noise. The bed is a lo-fi /
chillhop instrumental, ducked under the voice (see `/hyperframes-audio` carve). Pull
the SFX through `/media-use`. Every visual event has one sound:

| Event               | SFX                                                          |
| ------------------- | ------------------------------------------------------------ |
| Card / pop-in       | soft pop                                                     |
| Scene seam, zoom    | short whoosh                                                 |
| Cursor click        | mechanical mouse click                                       |
| Handwritten title   | pen / marker scribble (match the write-on duration)          |
| Paper note in / out | paper crumple or rustle                                      |
| Stamp               | rubber-stamp thud                                            |
| Checklist tick      | light tick / ding                                            |
| Typewriter          | quiet key ticks, randomized from a seeded list (determinism) |

Keep SFX around −18 to −22 LUFS-ish relative to the voice: present but never
competing.

## 7. Build checklist

- [ ] Workflow chosen (`/faceless-explainer` or `/general-video`), and this skill
      applied as the style layer
- [ ] User confirmed the bench variant (reference green or own palette) and whether a
      hook clip exists
- [ ] Tokens from §2 defined once on `:root`; three font roles only
- [ ] Every step opens with a paper note, and all content sits on dark cards
- [ ] No visual hold longer than ~1.5s without a new event
- [ ] Every scene exit is a cursor click into a seam
- [ ] Every visual event has its SFX; VO carved over the bed
- [ ] `npx hyperframes lint` and `npx hyperframes check` pass
