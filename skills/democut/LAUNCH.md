# Launch: a designed film, with the real product as its material

For a launch, promo, announcement or feature film. A walkthrough or tutorial follows `TASTE.md`
instead. Preflight, sign-ins, recording rules, the critic and export in `democut instructions`
still apply. This page replaces TASTE.md's look and pacing, and the walkthrough habit of
"one take, zooms, a voice, subtitles". The user's request and the product's own brand win over it.

**The one rule: a launch film is composed, not recorded.** At least 70% of its running time is
designed scenes that you draw as motion clips. The product appears in them as real pieces you
captured (stills, lifted elements), staged large. Live footage is used only where the product
must be seen working, 3 s at a time at most, and it is staged too. If your timeline is a take
with a title at the front and a card at the end, you have made a walkthrough.

## 1. Story and spec (before any tool)

1. Three storylines, one line each: hook, tension, reveal, proof, payoff, claim, end card.
   Pick one and say why the others lost.
2. The 3 to 5 beliefs the viewer must leave with. Each beat buys exactly one.
3. **The device.** Find the one mechanic that is the product (text turning bright as it is
   typed; a card being dragged; a diff resolving) and make it the film's motion language: how
   titles arrive, how scenes change. A film with a device looks directed; one without looks
   assembled. Write it in one sentence.
4. Fill the SPEC with numbers. Every adjective left in it becomes the generic default.

```text
GOAL     what the viewer feels or does at the end      PRODUCT  the real product; its takes and stills
OUTPUT   W×H, fps, seconds, BPM, frames per beat       BELIEFS  B1…B5, each bought by beat n
DEVICE   the product's own mechanic, used as the film's motion
LOOK     ground(s), ink, waiting ink, one accent: hex, all read from the product's own CSS;
         display face and size in px; hero size as % of the frame
MOTION   ease and seconds per role
SCENES   per scene: beats (from, to), designed or live, the ONE hero move, what is read, the
         sound, the hand-off to the next
QA       the frames to check and what each must show
```

| Format | Length | Scenes | Designed share |
| --- | --- | --- | --- |
| Social cut | 12 to 20 s | 5 to 7 | 80% or more |
| Launch film | 20 to 45 s | 8 to 14 | 70% or more |
| Feature film | 45 to 75 s | 12 to 20 | 60% or more; a demo beat may hold 7 to 10 s while the UI acts |

## 2. The look comes from the product

- Read the product's own colours and faces from its page (`democut browser eval` on
  `getComputedStyle`: background, text, muted text, accent; the `font-family` of its headline
  and of its body). Those are your ground, ink, waiting ink and accent. Use the product's own
  fonts when they are open-licensed (bundle the files beside the clip); otherwise the closest
  bundled face, and say so.
- Because your ground is the page's ground, a captured piece of UI sits on it with no border, no
  matte and no shadow: it simply is on the canvas. This is what makes "lifted" UI look designed
  instead of pasted.
- A second ground for floods: the accent, full frame, with the ground colour as its ink.
- Type is big. A hero line is 15 to 30% of the frame height and fills 60 to 90% of the width.
  A quiet line is 3 to 5%. Nothing between: the contrast is the design. At most 4 words a line.
- No narration by default and no subtitles: the type carries the words. Add a voice only when
  the user asks for one, and then drop the type that repeats it.

## 3. How to build it

1. **Capture the material** in DemoCut's browser, before any design:
   - the takes: one short take per live beat (5 to 10 s each), not one long session;
   - stills: `democut browser screenshot` of each state you will stage (2 px a CSS px);
   - boxes: one `democut browser eval` returning `getBoundingClientRect()` of every piece you
     will lift (the number, the chart, each row), saved as JSON beside the still. A piece is then
     a crop of the still at its box: pieces stay pixel-aligned with each other at any scale;
   - make the page itself bigger when the product lets you (its own font-size or density
     setting), so live footage needs less zoom.
   - record at 1280×720: a 2× still is then 2560 px wide and is never upscaled on a 1920 canvas;
   - read anything you will type or click after the page has settled and after your first click
     on it (a click can restart a test or re-sort a list).
2. **One timeline file.** Put every designed scene in one script (`film.js`) that draws the frame
   at film time `t`, with scene times in beats. Each clip page (`s1.html` …) sets a window
   `{from, to}` of that timeline. Scenes then stay in sync with each other and with the music,
   and a retime is one number.
3. **Render and place**: `democut motion render --html s1.html --add --start <from>`. A clip is
   opaque where the scene is designed and transparent where live footage shows through. A wipe
   between a designed scene and live footage is a shape in the clip moving off the frame.
   Check a placed clip with `democut frames --rendered --start <s> --end <s> --fps 6`, not a
   sheet you build yourself.
4. **Timeline under the clips**: the takes, cut so each live beat sits under its transparent
   window, with any footage as filler under opaque scenes (it is never seen). Then:
   - a zoom that must hold up to a cut ends a second after the cut, under the next opaque scene
     (a zoom starts easing out before its end), and starts a second before its reveal;
   - move from one framing to the next while an opaque scene covers the footage;
   - park the pointer off frame (`set_cursor_track` with one event at 0.999, 0.999) in any take
     where it does nothing;
   - end a live beat on something the product does (a fade, a panel closing), on the beat.
5. **Motion blur inside a clip is yours to draw** (`motion render` has no shutter): give each
   fast mover a directional blur of about a third of the distance it travels in half a frame.
6. **Music first, then the grid.** Use music only from a file the user gives you
   (`democut import <file>`); never download tracks or search this Mac for audio. With none,
   still pick a BPM. Before you time anything, set
   the BPM in the timeline file; every scene starts on a beat and every new composition on a bar where you can.
   A hit is a cut or a 0 ms change, never an eased arrival; a move that must land on a beat
   starts early so it lands there. Read the track's structure (energy per bar) and put its lift
   on your reveal and its own ending on your end card. If the product's reaction lags the key
   that causes it, put the reaction on the beat, not the key.
7. **Sound effects on the hits.** `democut sfx --at <s> --kind whoosh|impact|riser|click|key`
   places one sound with its hit at that time: one on each hit you designed. `democut sfx --auto`
   leaves out footage a designed scene hides, so in a film it adds little. Four or five in a
   film.
8. **Keep a clip's layers small.** Many full-frame layers in one page (a wall of tiles) make the
   renderer drop other content with no warning. Pre-render the tiles small
   (`motion render --size 960x540 --duration 0.1`: a clip is at least 0.05 s, so use its first
   frame) and let the camera scale them up.

## 4. Scenes

Use when · beats · how · pitfall.

1. **Typed title (the device as title).** The hook · 4 beats · the line waits in the muted ink
   and the product's own cursor types it, one letter a 16th note, no translate, no fade. Frame 0
   already shows the first words typed · a blank first frame; a title that fades up.
2. **Flood.** A scene change · half a beat · an object already on screen (a caret, a button, a
   chip) grows to the full frame in 0.3 s on `in`; the next scene is its colour, or it wipes off
   the far edge on `expo.out` to uncover live footage · a flood from nowhere.
3. **Statement on the accent.** One claim · 2 beats · 2 to 3 words at 20 to 25% of the height on
   the accent ground, the last letter or the full stop landing on the beat · more than one a film
   is a slide deck.
4. **Live, staged.** The product working · 5 beats at most · footage through a transparent
   window, pushed in until the working part fills the frame, cursor at 5 to 7% of the height
   with the designed press (`cursorPress:"designed"`), one punch-in on a beat · the page's
   header, footer or a browser bar in frame.
5. **The number.** A result the product computed · 2 beats + the read · the real value rolls up
   in numerals of 40 to 50% of the height, values held 2 frames, landing on a beat; then it
   shrinks onto the real number's own box in the still and is swapped for the real pixels · a
   number the product did not produce.
6. **Lifted pieces arrive.** The proof · 4 to 6 beats · crops of one still at their real layout,
   1.3 to 1.6×: the chart draws on with a left-to-right mask, each stat lands 1.14 → 1 on
   `expo.out`, 60 ms apart; then everything is still for the read · all pieces at once; pieces
   rearranged into a layout the product does not have.
7. **Montage.** Breadth (themes, templates, integrations) · 5 beats · real stills full bleed, cut
   1, 1, ½, ½, ½, ½, ¼, ¼, ¼, ¼ beats, each with its real name set large; arrivals 1.045 → 1 ·
   even cuts; invented variants.
8. **The wall.** "There are many" · 6 beats · pull back from the last montage still to a tilted
   grid of all of them (scale 1 → 0.27, tilt 30°, 0.95 s `inOut`), then a slow constant drift; a
   band in the ground colour crosses with the real count · the count must be read from the
   product, not remembered.
9. **End card.** Always last · 6 to 8 beats · the band grows to become the ground; mark lands
   0.8 → 1 `expo.out`, wordmark wipes out from behind it, the URL is typed by the device, a small
   credit; still for 1.4 s at most.

A live beat may also take one camera move (a push-in, punch-in or pull-back with
`democut zoom --element`, a click-to-cause cut, a cursor entrance), never more.

## 5. Motion

| Role | Ease | Time |
| --- | --- | --- |
| Arrival | `expo.out` or `power4.out` | 0.35 to 0.6 s |
| Move, camera, mask draw | `inOut` | 0.5 to 0.95 s |
| Exit, flood | `in` | 0.25 to 0.4 s, cut at its fastest frame |
| Pop | `spring` damping 0.75 to 0.85 | |
| Roll, drift, progress | `linear` or held values | |

Landed text is dead still and stays 0.5 s + 0.3 s a word. One hero move per scene; secondary
moves start 60 to 200 ms after it. Vary the entrances: if two scenes in a row enter the same way,
change one.

## 6. Truth

- The product on screen is the real site, recorded or captured by DemoCut. No invented UI,
  numbers, features or claims. A still is shown as the page drew it.
- Typing and other human actions happen at a person's pace (`--speed natural`, or
  `--wpm 90` for a typing product). Jump cuts inside typing are fine; speed-ups are not.
- You may hide a cookie banner and an empty ad slot. Prefer the product's own setting for it.
- Drive the page with `democut browser` commands (click, type, hover, key). If the shot needs
  an input they lack and you send it by script, the product's response must be what a person's
  input produces, and you say so in the delivery.
- A count ("187 themes") is read from the product on the day, and the read is saved.
- If the film could be mistaken for the product's own advert, the end card carries a credit line.

## 7. Banned

Unless the product's own brand does it, and then only as it does.

- **Look:** a dark or pale void with small things floating in it (the hero of every scene fills
  40% of the frame or more); glow, flares, orbs, particles; purple-blue or mesh gradients, glass;
  cream paper with a serif and "01 / 02" labels; corner labels, frame borders, brackets, HUD
  readouts; three cards in a row; a title over a dimmed screenshot; a sparkle standing in for the
  product thinking; a browser window, toolbar or URL bar; a subtitle bar.
- **Motion:** everything fading in at once, or fading and sliding up; one ease on everything;
  text moving while it is read; a slow push late in a scene; bounce on UI; crossfades between
  worlds; a plain zoomed take for more than 3 s; more than 3 s of live footage in a row.
- **Content:** invented products, dashboards or buttons; typing into a prompt box as the opener.

**No longer banned in a launch film** (still banned in walkthroughs, storyboards and DemoCut's
own UI): a palette taken from the product; full-frame floods and bands in the product's colours;
real UI as a card on a designed ground; a tilted wall of many stills, once a film, never for the
one thing being read.

## 8. Check before you export

- `democut review --genre launch`, then its sheet of flagged moments: fix `lineUnread`,
  `deadStretch`, `firstFrameEmpty`, `textBelowFloor`, `endHold` and `pageChrome`. It reads text
  inside motion clips too. An `info` finding is a hint.
- **Designed share.** `plainFootage` and `plainStretch` are hints: plain footage (nothing
  designed over 40% of the frame, the product's picture still) beyond the table's share, or
  over 3 s in a row. Seconds where the product itself visibly moves don't count, and holding
  on it can be the right call: you decide.
- **One contact sheet at 2 fps** of the whole film (`democut frames --rendered --every 0.5`;
  Look and listen in `democut instructions`). Cover the words: can a stranger tell it from a
  screen recording in the first three tiles? Is the same composition on screen for more than
  six tiles?
- **A 6 to 10 fps motion sheet** across every flood, wipe, roll and pull-back: no jump, no blank
  frame, blur on the fast frames.
- **Beat check.** List each scene start in frames beside the beat it should sit on.
- Judge by sheets, not by single frames. One full re-take at most.
- One critic pass, with this page and the SPEC as its brief.
