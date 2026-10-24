---
name: duo-dialogue-listicle
description: "Vertical (9:16) listicle told as a fast comic DIALOGUE between two characters: a skeptic who asks the viewer's questions and an expert who answers. Both are cutouts in the bottom third and appear only while they speak. A looping 'satisfying' gameplay-style background fills the frame, a single caption word sits at center, and floating rounded cards in the top third illustrate every line: tool cards, a persistent numbered checklist that advances, an audit checklist, a counting timer, hazard-tape stamps and before/after screenshots. It ends on a comment-keyword CTA. Load when the user asks for a 'diálogo', 'conversa entre dois personagens', a 'top N ferramentas / dicas' reel, a 'brainrot' or Minecraft-background style, or the 'estilo do Homer'. [dialogue, two-characters, skeptic, listicle, top-n, tools, brainrot, gameplay-background, one-word-captions, checklist, hazard-tape, comment-cta, vertical, reels]"
metadata:
  internal: true
---

# Duo Dialogue Listicle: the skeptic and the expert

Learned from a reference reel the user liked (9:16, ~1:49, Portuguese). In it a cartoon
skeptic grills a creator about "5 tools that make your app not look like it was
made in 2006". The format works because **the skeptic voices the viewer's doubt**,
so every answer lands as a payoff. The background keeps the eye busy between payoffs.

This is a **format + style layer**. Route the build through `/hyperframes` (older
installs: `/general-video`), source voices, music and SFX with `/media-use`, and apply
this skill on top. It pairs with `paper-bench-explainer`: use that one for calm
didactic depth and this one for fast, funny, high-retention lists.

## 1. Rights first (non-negotiable)

The reference used a famous copyrighted cartoon character and footage from a
commercial game. **Do not reproduce either.** Do not clone the voice of a real person
or voice actor without their consent.

- **Skeptic:** an original mascot. Generate one (a simple, bold, flat-colour character
  with a strong silhouette), or use the user's own character.
- **Expert:** the user (a photo cutout or their own avatar), or a second original
  character.
- **Background:** the user's own screen-recorded gameplay of a game whose terms allow
  it, royalty-free satisfying loops, or a generated voxel / low-poly runner loop
  (for example Three.js in HyperFrames).
- **Voices:** the user's own voice for the expert. For the skeptic, the user's voice
  pitched or styled, or a stock TTS voice. Never a voice that imitates a known
  character.

Say this up front, briefly, when proposing the format. It is also better for the
brand: an original mascot becomes recognisable as _theirs_.

## 2. Layout (1080×1920)

```
┌──────────────────────────┐
│  [ floating card ]       │  top ~15-45%: one card per line, rounded 24-32px,
│                          │  white or near-black, soft shadow, slight float
│                     [@]  │  handle watermark: IG glyph + @handle, right edge ~45%
│          word            │  ~50%: ONE caption word, white, heavy sans, dark shadow
│                          │
│ (skeptic)      (expert)  │  bottom ~35%: cutouts, skeptic left / expert right,
└──────────────────────────┘  each visible only while speaking
     full-bleed looping gameplay-style background behind everything
```

- **Background:** a full-bleed video loop, muted, constantly moving forward. Swap the
  "biome" or scene every ~10-20s so it never feels like one long clip. It is never
  dimmed much. The cards carry contrast themselves.
- **Speaker toggle:** when a line starts, its speaker pops in (scale .92 → 1,
  `back.out(1.7)`, 0.18s). While talking, they bounce subtly (scaleY 1 → 1.02 on
  syllables, driven by the VO amplitude envelope precomputed to keyframes, which
  keeps it deterministic). The silent character pops out or stays half-hidden. A
  static "base" figure may remain as an anchor, as in the reference.
- **Captions:** word by word from the VO transcript (`/media-use` transcribe →
  word timestamps). Use one word at a time at ~84-110px, weight 800-900, white, with
  a 4-6px dark shadow. The word appears on its timestamp with a 2-frame pop. No
  sentence captions.

## 3. Card kit (top third)

Every line gets a new or changed card. Never let a card sit unchanged for more than
~3s. Cards enter with a short slide up + fade (0.25s, `power3.out`) and leave fast
(0.15s) or get replaced in place.

1. **Title card.** The subject in a chunky pixel / display font inside a dark
   terminal window (three traffic-light dots), with an accent glyph in the corner.
   It opens and closes the piece.
2. **Progress list ("5 FERRAMENTAS").** A dark card listing slots 1-N. The current
   item is highlighted with an accent bar (orange in the reference). Done items get
   a ✓. Future items are greyed placeholders. It comes back between items, so it is
   the spine of the video. Before item 1 it can appear as a branching diagram
   (title → N nodes).
3. **Tool card.** A repo / product card (name, one-line description, stars-like
   meta), a product logo tile, or a screenshot of the tool's site.
4. **Audit checklist.** A white card with criteria rows. Ticks and crosses resolve
   one by one with a counter ("2/5") updating.
5. **Timer card.** Big red mono digits on black with a small caps label ("ESCOLHENDO A
   COR"). The digits count fast to exaggerate a pain point (11:09 → 45:00).
6. **Hazard stamp.** Yellow plate with black-yellow hazard stripes, a ⚠ icon and one
   ALL-CAPS word ("VERGONHA", "PERIGOSO"). It slams in at 1.3 → 1 with a 2-frame
   shake. Use it for punchlines only, max ~3 per video.
7. **Before / after.** An ugly 2006-style site screenshot, then a polished one, or an
   inspiration screenshot, then a generated result. Show a curved arrow or the
   cursor between them.
8. **Code card.** A tiny dark snippet window with a few lines typing in.
9. **Summary card.** The final numbered list with each tool's source / link at the
   right. This is the "screenshot this" frame.
10. **CTA overlay.** Large two-line text over the background, _"Comenta" /
    "\"KEYWORD\""_, with the keyword in quotes and heavier. Hold ≥2.5s.

## 4. Script formula

Write it as a two-voice script, alternating lines of 1-3s. Target **60-90s for 5
items** (the reference ran 1:49, which is long). Cut filler before cutting items.

| Beat          | Pattern                                                                                                                                                                                    | Example shape                                                       |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| Hook (0-7s)   | Skeptic voices a relatable pain as a question, with a concrete contrast                                                                                                                    | "Why does everyone's app look like it cost 10k and mine like 2006?" |
| Diagnosis     | Expert, blunt, short                                                                                                                                                                       | "Because you're using it wrong. You're missing five tools."         |
| Echo          | Skeptic repeats the number                                                                                                                                                                 | "Five?"                                                             |
| Item loop ×N  | Expert: "Number X: <name>." → Skeptic: "And what does it do?" → Expert: one-line benefit → Skeptic: a joke / exaggeration of the old pain → Expert: a short confirm ("Exactly." / "Very.") |                                                                     |
| Surprise item | Skeptic: "What does that have to do with <topic>?" → Expert: "Everything."                                                                                                                 | builds the strongest payoff late                                    |
| Wrap          | Skeptic: "Okay, that's a little scary." → Expert: "And extremely useful."                                                                                                                  |                                                                     |
| CTA           | Skeptic: "Where do I get them?" → Expert: "I put them all together. Comment <KEYWORD> and I'll send you the list."                                                                         | comment-keyword DM automation                                       |

Rules: the skeptic gets all the jokes, the expert stays calm and short. Each item's
joke exaggerates a real pain the viewer has felt. The number of items is announced
in the hook and repeated on the progress card.

## 5. Sound

- Two clean VO tracks, tight: no gap over ~150ms between lines, with slight overlaps
  allowed for comedic interruptions.
- A light upbeat bed under the VO, carved for the voice.
- SFX: a pop per card, a whoosh on card swaps, a stamp thud on hazard plates, a
  ticking clock under the timer card, a success ding on ✓, an error buzz on ✗.

## 6. Build checklist

- [ ] Rights check done: original characters, licensed or own background, consented
      voices
- [ ] Script written as alternating two-voice lines, with a hook pain question in the
      first 3s
- [ ] Item count announced, and the progress card tracks it
- [ ] A card changes on every line, with no card static for more than ~3s
- [ ] One-word captions from word timestamps
- [ ] Speaker pop in / out plus an amplitude-driven bounce, precomputed so it stays
      deterministic
- [ ] At most ~3 hazard stamps, used only on punchlines
- [ ] Summary card and comment-keyword CTA at the end
- [ ] `npx hyperframes lint` and `npx hyperframes check` pass
