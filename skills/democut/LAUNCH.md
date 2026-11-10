# Launch: what a good DemoCut launch film looks like

For a launch, promo, announcement or feature film: a short, designed piece that sells one idea.
A walkthrough or tutorial follows `TASTE.md` instead. The flow in `democut instructions`
(preflight to critic) still applies; this page replaces TASTE.md's look
and pacing. The user's request and the product's own brand win over it.

## Story first

1. Write three storylines, one line each: hook → tension → reveal → proof → payoff → claim →
   end card. Pick one; say why the other two lost.
2. List the 3–5 beliefs the viewer must hold at the end. Each beat buys exactly one: a beat
   that buys none is cut, a belief no beat buys is a gap.
3. Each beat causes the next: a click, a result, an object that becomes the next world.
4. Then fill the SPEC with numbers. Every adjective left in it becomes the generic default.

```text
GOAL     what the viewer feels or does at the end      PRODUCT  the real product and its takes
OUTPUT   W×H, fps, length band                         BELIEFS  B1…B5, each bought by beat n
LOOK     ground, ink, one accent and where; type size per role
MOTION   ease and seconds per role; springs as damping
SHOTS    per beat: seconds, card, the ONE hero move, what is read and how long, sound, hand-off
QA       the frames to check and what each must show
```

| Format | Length | Beats | Beat |
| --- | --- | --- | --- |
| Social cut | 12–20 s | 5–7 | 1.8–3 s |
| Launch film | 20–45 s | 7–12 | 2–4 s |
| Feature film | 45–75 s | 10–16 | 3–6 s; a demo beat holds 7–10 s while the UI acts |

- **Pace.** Something new every 2–4 s; over 3 s unchanged is dead. The hook lands by 1.5 s.
  Frame 0 is the thumbnail: product or text, never empty. Montage cuts run 0.13–0.8 s,
  accelerating; hold 0.3–0.75 s before a payoff, which plays at real speed.
- **Text.** At least 2.6% of the short side (element `--size` 18.7; 28 px at 1080); titles
  4–9% of the height (size 29–65). On screen 0.5 s + 0.3 s a word (one word 0.8 s, two
  1.1 s); the last line 2 s. Too many words: cut words, never shrink type. Landed text is still;
  its exit is 40–50% shorter than its entrance. One accent word a line, only if it means
  something.
- **Eases by role** (`democut element key --ease`, `democut zoom --ease`): arrival `expo.out`
  or `power4.out` 0.3–0.6 s; camera move `inOut` 0.4–0.7 s; exit `in` at 0.6× its entrance; a
  pop `spring` (`--damping 0.75 --response 0.45`); rotation or progress `linear`. Damping 1
  never bounces, 0.7–0.85 is premium, 0.45–0.6 playful (rare), under 0.3 a cartoon. Opacity
  never overshoots. The next move starts when the last is 30–50% done; stagger words 60–120 ms,
  list items 40–80 ms. Vary by role: one ease on everything is the generic default.
- **Camera.** Magnify the action 1.6–3× (a prompt 1.6, a dashboard 1.7, a modal 1.4, one
  control up to 3) with a zoom or an element lift, never by shrinking the canvas. A move takes
  0.4–0.6 s, arrives where the cursor acts, then holds while the UI acts. A pull-back snaps to
  0.56–0.77 of the scale, then a 0.3–0.6 s tail. The hero fills 40% of the frame or more.
  Budget: one push and its pull-back a beat, 3 s apart or more; a punch-in (8) or zoom through
  a button (11) counts as a cut.
- **Cursor.** `style.update {cursorPress:"designed", cursorEntrance:1.8}` in
  `democut call edit`: 2 frames down, 3 up, the control reacting a frame after the bottom.
  A cursor 4–7% of the height (`cursorScale`, a 0.5–4 multiplier; check a rendered frame).
  Park 2 frames before an obvious button, 3–5 before a switch, 5–15 when the camera zooms onto it. The click causes the next beat on that frame.
- **Blur.** Keys and eased zooms blur in the export (180° shutter): 6–12 px on text-sized
  elements, 15–20 px full frame. Judge it on a 6 fps motion sheet (previews don't blur elements).
- **Sound.** `democut sfx --auto`: real recorded clicks, whooshes and impacts on the clicks,
  push-ins and lifts. About one a beat, never one per key; a riser only for a film that builds.
- **End.** The mark lands centred in the last 5–10%, 15–30% of the width. A real CTA (the
  button, or the command to type) is on screen 1.5–3 s, its entrance included; after the last
  move settles, hold 1.4 s at most (`endHold`), then cut. A Free export appends DemoCut's card: design for that cut.

## Shot cards

Use when · seconds · how, with the numbers that set its feel · pitfall.

1. **Kinetic title.** The hook · 1.2–2 · `democut motion template kinetic-title`, rendered with
   `--add --start 0`; or a text element a word, keyed scale 1.15→1 and opacity 0→1 by 0.25 s
   `expo.out`, 0.07–0.1 s apart, size 40–65 · over 1.4× is a bounce; one entrance a film.
2. **Hero push-in.** First look at the product · 2–3 · `democut zoom --element '<sel>' --start
   <s> --end <s> --ease inOut`, 1.6–2×, 0.4–0.6 s from 0.6–1 s in · the UI acts during the hold; over 0.8 s creeps.
3. **Element lift.** The proof is one component · 2.5–4 · `democut browser track --name card
   --selector '<css>'` before the take, `democut element capture --name card --scale 4`, then
   `democut element lift --name card --at <s> --scale 2.2 --hold 1.2`, which casts
   `shadow:"contact"` (`overlay.update` sets it on others; motion clips refuse it) · a
   lift tops out at 3×: past it, with a zoom on top, capture at 4×; labels must not jump.
4. **Wipe with a cause.** A transformation · 1.5–2.5 · a `--shape box` in the ground colour
   keyed across x over 0.4–0.6 s `inOut` from the press frame, after 0.8 s of "before" · with
   no cause on screen it is a slideshow.
5. **Counter roll.** A number the product computed · 0.8–1.2 + read · `democut motion template
   counter` with its real values, rendered with `--add`; 9% of the height · a number the
   product didn't produce is an invented claim.
6. **Cursor entrance.** A scene's first click · 0.5–0.9 · `cursorEntrance` 1.5–2.2 · one cursor;
   even-speed travel reads robotic.
7. **Click-to-cause cut.** A click opens a new world · 5 frames · designed press, cut on the
   reaction, the next shot arriving 1.04→1 on `expo.out`, one click sound · no ripple rings.
8. **Punch-in.** A detail inside one scene · a cut, then the hold · `democut zoom --click <at>
   --ease expo.out`, 1.6–2.5×, cut on an action · 2 a scene; a third of beat seams at most.
   Review's `framingJump` there is expected.
9. **Pull-back reveal.** The result returns to its system · 1 frame + 0.3–0.6 · a second zoom
   `--transition direct --ease expo.out` at 0.56–0.77 of the first's scale · labels hold still.
10. **Whip pan.** A sideways cause (swipe, next tab) · 0.2–0.4 · out on `in` toward the exit,
    cut at the fastest frame, in on `expo.out` the same way · 2 a film; directions match.
11. **Zoom through a button.** A launch or publish click · 0.6 + 0.35 · zoom `inOut` to it,
    place its capture on its box (`overlay.add {kind:"image", from:{element, at}}`), key it to
    scale 10 in 0.35 s on `in`, cut to a scene in its exact colour · once a film.
12. **Object becomes the world.** Entering a detail from a card · 0.65 · key it to fill the
    frame `inOut`; the next scene fades in over its last 40% · never crossfade worlds bare.
13. **Result fills in.** The product doing the work · 2–7 · a 1.6–2× zoom settled before the
    result; `timeline.speed` up to 2× on the dull middle, 1× for the payoff · no creeping push.
14. **Word by word.** A claim line · 60–120 ms a word, then the read · an element a word keyed
    opacity 0.3→1 in 0.13 s `expo.out`, no translate · never fade-and-slide-up.
15. **Callout.** Directing the eye where a zoom would lose context · 0.3 in, the read, 0.15 out
    · `--shape highlight` keyed scale 1.08→1 `expo.out`, the one accent · one at a time, no glow.
16. **Lower third.** One phrase while the UI acts · the read · `--preset lower-third`, 6 words
    at most, in from x −0.02 on `power4.out` 0.35 s, out 0.2 s `in` · never over the action.
17. **Chapter line.** Between acts of a 30–45 s film · 0.8–1.1 · 1–2 words at size 43–65,
    scale 1.06→1 in 0.2 s, on screen 0.8 s (one word) or 1.1 s (two) · over 3 a film is slides.
18. **Montage.** Breadth after one deep proof · 2–4 · 4–8 real results cut 0.8, 0.6, 0.45, 0.3,
    0.2 s, the last held 0.5 s with one impact · even cuts read as a slideshow.
19. **End card.** Always last · 2.5–4 · `democut motion template end-card`, or the mark keyed
    0.8→1 `expo.out` 0.5 s, the wordmark following at 40%; a real CTA on screen 1.5–3 s
    with its entrance, still 1.4 s at most · never a docked logo or everything fading in at once.

## Banned

Unless the product's own brand does it, and then only as it does. After each film, tell the user
every default its frames used anyway.

- **Look:** a dark void with small things floating in it; glow, flares, orbs, particles;
  purple-blue or mesh gradients, glass cards; cream paper, serif and "01 / 02" labels; corner
  labels, frame borders, brackets, HUD readouts; three feature cards in a row, KPI grids, a
  title over a dimmed screenshot; UI tilted in 3D; a small window on an empty canvas; a sparkle
  standing in for the product thinking (show the real result).
- **Motion:** everything fading in at once, or fading and sliding up; one ease on everything;
  linear moves that aren't rotation or progress; text moving while it is read, or drifting or
  pulsing after it lands; a slow push late in a scene; bounce on UI; whole-frame shakes over 3
  a film; every scene entering the same way; crossfades between worlds; even-speed entrances.
- **Content:** invented products, dashboards or buttons; typing into a prompt box as the opener.

## Case law

Verdicts on earlier films; each still holds.

- **Real, popular products** people use and would stop scrolling for; never one safe demo
  product everywhere, never an invented app. **No face, no bait** ("comment for the link").
- **Big, legible actions:** three or four large ones that visibly happen; no tiny step lines,
  tiny UI or dead frames; about 1 s of typing at a person's pace (`--speed natural`, never
  brisk). **Few elements:** the CTA never drowns.
- **Honest labels:** a file name, not a bare brand name, on a clip; no product name in our own
  chrome. **Succinct copy:** the shortest true line, never a list of options on a card.
- **Pixel-honest edges:** no edge fades or flicker; labels snap to whole pixels.
- **No inception:** a DemoCut result inside a film is real footage, with no gradient frame
  inside its preview; loops cut hard at natural boundaries.
- **Calm, product-agnostic styling:** no brand slabs, dark bands, coloured mattes or borders
  round screenshots; never tune the palette to the product; judge on a light and a dark
  UI. **No invented UI:** no notes boxes; a click is a real pointer, not a target circle.
- **Honest coverage:** never imply cuts that don't exist or show part of the text as all of it.
- **Sharp previews:** review stills at full resolution.
- **Real sounds:** recorded, CC0, licence kept; no game or UI sound packs.

## Check before you export

- `democut review --genre launch`: fix `lineUnread`, `deadStretch`, `firstFrameEmpty`,
  `textBelowFloor`, `endHold` and `pageChrome`. An `info` `textBelowFloor` is small product
  text: magnify it if the viewer must read it.
- One `democut frames --rendered --times` sheet of every beat. Describe each frame in a sentence
  as a stranger would; with the words covered, the frames still tell the story.
- A 6 fps motion sheet across every lift, whip and push: no jump, labels steady.
- Notes as `t=4.2s · where · problem → exact change · what stays`, ranked P0, P1, P2; fix the
  P0s, then the P1s worth it. Never a score out of 10.
- One critic pass, with this page and the SPEC as its brief.
