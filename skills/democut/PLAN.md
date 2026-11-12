# Editing with a plan file

A plan file is the main video as JSON: its shots in order, and for each shot its captions,
on-screen text, cutaways, zooms, crop and sound level. Export it, change it, apply it. Apply
makes the project match the file as one undoable edit.

## Plan or single command

Use a plan for cuts, trims, reordering, captions, plain text, cutaways, crop, levels, and any
edit that touches several shots. Use a single command for the rest: a zoom framed on what the
take recorded (`democut zoom --click`, `--element`, `--region`), a title or other styled element
(`democut element add`), narration (`democut narrate`), transitions, the canvas shape and the
caption style (`democut call edit`). A plan leaves those as they are, and export's `note` names
what it left out.

## The loop

1. A plan names its project by file. A new project has none: save it first with
   `democut call project_save '{"path":"/absolute/name.screencap"}'`.
2. `democut plan export --out plan.json` (`--overwrite` to replace the file).
3. Change plan.json. Never edit the .screencap file itself.
4. `democut apply plan.json --dry-run`. It changes nothing. Read the report; fix every problem.
5. `democut apply plan.json`. It writes the project's .screencap file at once, as every edit
   does: there is no separate save. plan.json is only your copy.
6. After another command changes shots, captions, text, cutaways or zooms, export again before
   you change the plan.

## An example

```json
{
  "plan": 1,
  "project": "/Users/me/demo/demo.screencap",
  "levels": {"voice": -16},
  "styles": {"label": {"size": 40, "color": "#ffffff", "y": 0.12}},
  "shots": [
    {"source": "take-1.mov", "in": 2.0, "out": 6.5, "level": "voice",
     "captions": [{"start": 2.2, "end": 4.0, "text": "Open the dashboard"},
                  {"start": 4.0, "end": 6.4, "text": "Pick a report"}],
     "text": [{"text": "Step 1", "style": "label"}]},
    {"source": "take-1.mov", "in": 12.0, "out": 15.0,
     "zooms": [{"start": 12.5, "end": 14.5, "scale": 1.6, "x": 0.8, "y": 0.2}]},
    {"source": "take-2.mov", "in": 0.0, "out": 3.0,
     "cutaways": [{"source": "logo.mov", "in": 0, "out": 2,
                   "frame": {"x": 0.6, "y": 0.6, "w": 0.35, "h": 0.35}}]}
  ]
}
```

- `project`: the open project's file, as export wrote it.
- `shots`: the whole main video, in order. A shot is `source` (the imported file's name), and
  `in` and `out`, the seconds of that file it plays. Leave out a shot and it is cut.
- `captions`: `{start, end, text}`.
- `text`: plain on-screen text. Each entry names a style from `styles`; its times default to
  the whole shot.
- `cutaways`: another video over the shot from its `at` (default `in`), its `frame` in shares
  of the canvas (default the full frame), silent unless given `volume`.
- `zooms`: `{start, end, scale, x, y}`. `x` and `y` are the anchor, the point of the source
  frame that stays in place as the view grows (0.5, 0.5 zooms on the centre; 0.8, 0.2 toward
  the top right), not the centre of the view. They are in the whole source frame, even on a
  cropped shot.
- `level`: a name from `levels` (built in: `voice` -16, `ambience` -21, `music-bed` -28, `mute`).
  Apply measures the shot's own sound and sets its volume. Or give `volume`, a gain 0 to 16.
- A plan has no ids, tracks or revisions.

## Times are SOURCE seconds

Every time in a plan is seconds into that shot's source file: `in`, `out`, caption and text
`start`/`end`, zoom `start`/`end`, cutaway `at`. Each one must lie inside its shot's `in` to
`out`. Above, the caption at 2.2 plays 0.2 s into the video, and shot 2's zoom at 12.5 plays at
4.5 + 0.5 = 5.0 s.

Everything else uses OUTPUT seconds, the finished video's: `democut events`, `review`,
`frames --rendered`, `zoom --start`, `call edit`. A source time `t` in a shot plays at
`at + (t - in) / speed`, where `at` is the shot's start in the video (apply's report gives it).

## A missing key keeps; an empty list removes

- No `captions` key: the shot keeps its captions. `"captions": []`: they are removed.
- A list replaces the shot's whole list. To change one caption, keep the others in it.
- The same for `text`, `cutaways` and `zooms`. A `zooms` list owns every zoom over that shot.
- `crop`: left out keeps it, `null` clears it.

## Edits people ask for

Trim a shot: change its `in` or `out`. Move its captions inside the new range, or drop the ones
now outside it.

```json
{"source": "take-1.mov", "in": 2.0, "out": 6.5}       before
{"source": "take-1.mov", "in": 3.1, "out": 6.5}       after: 1.1 s cut from the start
```

Reorder: move whole shot objects in `shots`. Cut a middle part: split one shot into two with
the same source.

```json
{"source": "take-1.mov", "in": 0, "out": 20}                                      before
{"source": "take-1.mov", "in": 0, "out": 8}, {"source": "take-1.mov", "in": 12, "out": 20}  after
```

Add a caption, or fix one's words: edit the shot's list.

```json
"captions": [{"start": 2.2, "end": 4.0, "text": "Open the dashbord"}]          before
"captions": [{"start": 2.2, "end": 4.0, "text": "Open the dashboard"},         after
             {"start": 4.0, "end": 6.0, "text": "Pick a report"}]
```

Add a cutaway (import its file first with `democut import <file> --no-place`):

```json
"cutaways": [{"source": "closeup.mov", "in": 1.0, "out": 3.5, "at": 4.0}]
```

Crop to vertical 9:16. Set the canvas once (`N` is the `revision` export printed), then crop
each shot to a column of its frame. For a 16:9 source the 9:16 column is `width` 0.3164; `x`
from 0 (left) to 0.6836 (right), 0.3418 to centre it.

```sh
democut call edit '{"expectedRevision":N,"operations":[{"method":"style.update","params":{"aspectRatio":"9:16","padding":0}}]}'
```
```json
{"source": "take-1.mov", "in": 2.0, "out": 6.5, "crop": {"x": 0.3418, "y": 0, "width": 0.3164, "height": 1}}
```

A plan carries no revision, so your plan still applies after that edit.

Set levels: `"level": "voice"` on each shot with speech, `"level": "mute"` to silence one.

Add a zoom: in the plan, `{start, end, scale, x, y}` in SOURCE seconds (scale 1.3 to 2 reads
well; at least 1 s long). To frame a click or a page element exactly, use
`democut zoom --click <at>` or `democut zoom --region x,y,w,h --start S --end E` (OUTPUT
seconds) instead, then export again.

## Reading a dry run

The report lists every shot with `change`: `kept`, `trimmed`, `split` or `inserted`, `at` (its
OUTPUT start) and `was` (its range before). `text`, `cutaways` and `zooms` count what was
`added`, `removed` or `changed`. `captions` counts the shot's list as replaced: a fixed caption
is one `removed` and one `added`. `removed` lists cut clips. `sideEffects` lists what the cuts
moved, shortened or removed, captions included. `notes` has warnings, such as a level held down by the peak guard or
a crop that changes nothing. `applied` is false for a dry run, and for a plan the project already
matches.

Errors change nothing:

- `plan_invalid`: every problem at once, in `problems: [{at, message}]`. `at` is the path
  (`shots[2].captions[0].end`); the message names the shot and says what to do. Fix them all,
  then dry-run again. A problem at `project` after an export that wrote `"project": ""` means
  the project has no file: save it (step 1), then export again.
- `plan_project`: the plan's `project` isn't the open project. Open that one, or export again.
- `stale_revision`: the project changed since you read it. Export again and redo your change.

## Mistakes to avoid

- OUTPUT times in the plan. Convert them to the shot's source seconds first.
- Ids. A plan has none; shots are matched to clips by source and range.
- Editing the .screencap file, or keeping an old export after other edits.
- Applying without a dry run, or stopping after the dry run.
- Telling the user the .screencap is unchanged after an apply. Apply wrote it. To keep the
  original, copy the .screencap file before you apply.
- A caption, text or zoom outside its shot's `in` to `out` after a trim.
- A source name that isn't imported: the error lists the imported names.
