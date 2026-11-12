# Taste: what a good DemoCut demo looks like

Defaults, not laws. The user's request and the product's brand win. Read this before you plan
the shots, and again before you export.

## Story

- One viewer, one job: who is this for and what should they do after watching? Cut anything
  that doesn't serve that.
- Know the product before you storyboard. Unless the user gave the full context, read its site
  and docs, its common workflows, and the standout features and settings worth trying. Pick the
  one task that shows the value best, then rehearse it.
- Open on the outcome or the problem in the first 3 seconds: the product already on screen,
  never a loading page, a login or an empty state.
- Show one real task end to end, in the order a user does it. Each beat shows one idea.
- End on the result, held for 1.5–2 s, then a one-line call to action, then stop. End clean:
  close any menu or panel and clear the selection, so the result is what the viewer sees.
  45–90 s for a product demo, under 30 s for a social clip; never pad a shot to reach a length.
- A storyboard of existing footage tells the truth about it: every real cut, or one continuous
  take said plainly (`"continuous": true`); stills with the planned title, captions and framing
  (`democut frames --rendered`), or labelled raw; every caption or script line, not a sample.
  Look at the footage first (`democut frames --file <clips…> --every 2`, before importing) and
  read what was said (`democut transcript <clip> --prompt "<names>"`).
  The grid suits distinct shots; one long take with many lines reads better as `"layout": "list"`.

## Recording

- Rehearse the path first and fix anything slow or flaky before the take: a rehearsal take,
  checked, then the real one. Budget time for one re-record; when the problem is in the
  footage (typing pace, pointer placement, junk files, a wrong state on screen), re-record
  that part as a pickup take rather than editing around it.
- Capture whole sequences: the action, the response and the result, in one take. A readable
  pause on real UI is fine; recorded footage doesn't need constant motion. (The 3 s hold rule
  below is about dead, silent stretches, not a result the viewer is reading.)
- Size the window for the video: on-screen text grows by about export width ÷ window width in
  points (a bit less with padding), so aim for 1.4 or more. A window that fills a big display
  makes every word tiny, and zooms can't rescue a whole video. For a text-heavy page, settle
  this before the first take: a short test take, then
  `democut legibility` and a full-frame rendered frame; body text should read easily. Later,
  small text is fixed with a zoom in the edit; re-record at another size only when text is
  unreadable even zoomed in.
- Clean slate: realistic sample data (no lorem ipsum, no real people's data), no notifications,
  banners, cookie prompts, dev tools or unrelated tabs. Same window size and theme in every
  take. Numbers on screen must add up: totals equal their parts. Set the product up so its
  output is clean too: a project with a `.gitignore` shows no cache or build files in a diff.
  You may hide what isn't the product (cookie or consent banners, ad slots and placeholders,
  chat bubbles and other overlays), for now with CSS injected by `democut browser eval`. Never
  hide product UI, prices or other people's content.
- Never leave an error or invalid state on screen, even for a moment, such as a syntax error
  while code is half typed. Type text that is valid at every step, or cut the moment.
- Move the pointer like a person showing someone: straight to the target, a short settle, then
  click. No wandering or circling, and no parking it over what the viewer is reading: after
  the click, move it aside before a hold on text or code.
- Show the real interaction. Type the prompt on camera (`democut type`, or the snippet's
  `__democutType` in a browser), press Enter or click Send on camera, and keep the moment the
  input moves into the thread and the first response appears. Cut the waiting between, never
  the actions themselves. Never paste or set a field's value at once.
- Type at the pace you want it seen (`--cps`, so the typing lasts as long as the line over it)
  and don't speed it up. If it must be faster, one constant speed over the whole span (2×),
  never a faster middle: a ramp inside the words makes the typing lurch. Move the pointer off
  the field before typing, so it never sits over the words.

## Edit

- Cut every wait: loading, typing you don't need to watch, scrolling to find something. Keep
  about 1 s of a load if it shows that something real happened.
- Calm beats busy. The viewer should never feel the camera: few zooms, slow moves, no jumps.
- Moves ease with a long, smooth deceleration; never a bounce or an overshoot. Entrances take
  longer than exits.
- One new thing at a time: don't start a zoom while a caption appears and a menu opens. Let
  each land before the next begins.
- Zoom only when the detail matters and is too small at full frame: usually 1.4–2×, held long
  enough to read (at least 2–3 s). As a rough budget, one zoom per beat and no more than one
  every 8–10 s. Not on every click.
- Open wide for 1–2 s to establish, never already zoomed in. Zoom in 0.5–1 s before the action
  starts (take the times from `democut events`), hold through its result, and zoom out when
  attention moves on. Never zoom at a random moment. Always zoom a click on a small target (an
  icon, a checkbox, a menu item): at full frame nobody sees what was clicked.
- Stay zoomed while the action stays in one area (one zoom over the steps, or transition 'direct'
  on the next zoom); don't zoom out and back in between steps.
  Zoom out before moving to a distant part of the screen, never jump from one zoom to another.
- Never cut between two different framings (zoomed to wide, or one zoom to another): the
  frame jumps. A cut inside one zoom, with the same framing either side, is fine. Keep each
  zoom's ease in and out whole, away from cuts.
- Fewer, longer shots. A cut every 2–3 s feels frantic; 4–8 s per shot is calm.
- Frame the whole element plus a little context: the button and its label, the menu that
  opens, the result that appears. A zoom on typing shows the field and the dialog or panel it
  sits in, header included. Name what the take recorded (`democut zoom --click`, `--element`)
  rather than guessing a rectangle. A zoom's edges fall on panel boundaries or empty space,
  never through a line of text.
- Nothing static for more than about 3 s, narrated or not: show the next step or cut the
  shot. A frozen screen under a voice reads as a broken video too.
- The key result gets the longest hold in the video. Never three low-energy beats in a row.
- Hard cuts by default. Use a dissolve only between scenes, never inside one action.
- Keep the default style (background, padding, rounded corners, caption box) unless the user
  or brand asks otherwise. No custom caption colours. The default background is `wash`, soft
  light-blue silk; `dune` is the same in warm sand and cream. The other presets (`dusk`,
  `ocean`, `sand`, `midnight`, `rose`, `forest`) are two-colour gradients.

## Words

- Narration says why, the screen shows what. Don't read the UI aloud. Each text beat is one
  claim, then the picture that proves it. Name the product at the open and the close, not in
  every line.
- When a line says "this", "here" or "see", that thing is in frame and unobstructed at that
  moment. The result appears on, or just before, the word that names it.
- Short, plain sentences in the second person ("you"), one claim each, no hype words.
- Write a line as it should read on screen: URLs, numbers and names as text ("example.com"),
  never spelled out for the voice ("dot com"). The voice reads them; the captions show the text.
- Write the script against `democut events`. Each line starts 0.2–0.5 s before the action it
  names and describes only what is on screen then. Re-check with the motion sheet's word strip,
  and fix every `narrationGap` the review lists.
- Captions subtitle the narration: `democut narrate` adds them, one short line per cue; keep
  them unless the user asks for none. They're a default: edit, retime or remove them when the
  user asks. A title is an element (`democut element add --preset title`), not a caption.
  Without a voice, captions carry the script the same way.
  Check spelling and product names (`democut transcript --timeline` lists every caption). No
  cue under about 0.35 s; break at pauses; keep captions clear of the zoom's target.
- Music is optional. Use it only when the user gives you a file; never download tracks or search
  this Mac for audio. Start the track at a strong section, not its quiet intro; duck it about 12–15 dB under the voice; fade it out before the
  call to action.

## Check before you export

- After each edit, run `democut review` and read its sheet of flagged moments. Open a single
  frame or a 6 fps motion sheet (`democut frames --rendered --start S --end E --fps 6`) only
  for a moment it flags.
- Once review is clean, look at one `democut frames --rendered --times` sheet of the beats
  (every zoom, every cut, the first and last second; `--every 0.5` for the whole film), not
  frame by frame: the key element is
  fully in frame and sharp; nothing is cut off, blank or mid-load; no error on screen, no
  overlay, pointer glitch or browser chrome; the end is clean.
- Watch at the final speed (with narration, read a motion sheet's strip): no dead air over
  about 1 s, no line that runs over the next action, and the narration's claims match the
  screen.
- Where UI text matters, its labels on the beats sheet must read and match the source. After
  two tries at a tighter zoom, say which screen won't read at this size.
- Audio: voice near −16 LUFS, no clipping, music clearly under it; fix review's loudness
  findings. `democut loudness --shots` gives each shot's loudness and the volume that reaches a
  level. Raise quiet clips with their volume (up to 16, +24 dB; a video's own sound is its
  linked audio clip): DemoCut's export limits peaks to −1 dBTP, so deliver its file as it is,
  with no gain pass after.
- Zoom or crop where `democut legibility` marks text `small`; check its `words` hold the nouns
  the narration names.
- Length and aspect ratio match the request. Export at 1080p or more: UI text is small, and
  a dense app needs zooms to be readable on a phone.
- One critic pass, once review is clean: fix its Blockers, then check the fixes yourself on a
  rendered sheet and `democut review`. Never a second critic, even after a pickup take.
