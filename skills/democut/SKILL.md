---
name: democut
description: Make product demo and walkthrough videos with DemoCut, the screen recorder and editor on this Mac. Records exactly a browser page, gives an automated browser session a natural cursor, edits (cuts, zooms, captions, titles, transitions), adds a narration on Pro (DemoCut's AI voice or a voice on this Mac) or captions, and exports an MP4. Use when the user wants a demo, tutorial, launch or promo film, or screen-recording video, or wants a DemoCut project edited or exported.
---

# DemoCut

Drive DemoCut with the `democut` command, by the path written here (it needn't be on the
PATH). It opens DemoCut in the background when it isn't running.

1. **First, every task:** run `democut preflight` (`--media` the user's files and export folder) and
   give the user each blocker's `fix`. Then, before you plan or record, send your first message as
   reply text (thinking and progress updates don't count). It holds only the lines preflight's
   `next` gives, as they are (on Free: captions instead of narration, and a short DemoCut end card).
   If someone can answer (an interactive session) and the request lacks the subject or the length
   (you judge), ask this question, word for word: "Want to see a storyboard first, or go straight to
   the video?" Your whole reply is those lines and that question; the user answers next. Ask it as
   your own, with no word on where it comes from, and don't pick one or say which you'll take.
   Otherwise write those lines in your reply before your next command, go straight to the video and
   end the delivery message with exactly: "Want a storyboard first next time? Ask for one." Requests
   win: a storyboard first if they asked for one, no questions if they said so. On Free, a generated
   voice counts as narration (DemoCut's AI voice, a Mac voice or any generated audio file): use
   captions. The user's own recorded voice is fine. Say a later `notice` unless your reply text did.
2. Then run `democut instructions` and follow it, even if you read it or this page earlier in
   this thread. It comes from the installed DemoCut, so it is current; where it and this page
   differ, it wins. If its output doesn't start with "# Making a video with DemoCut", ask the
   user to update DemoCut.
3. Before you plan, read `TASTE.md` (next to this file) for a walkthrough or tutorial, or `LAUNCH.md` for a launch, promo, announcement or feature film,
   and use its checklist before you export. The user's request wins over either. After each edit, run `democut review` and read its sheet; open a single frame only for a moment it flags. For the final check, one `democut frames --rendered --times` sheet of the beats. One critic pass, once review is clean: fix its Blockers, then check the fixes yourself, never with a second critic.
4. Run `democut help <command | tool | operation>` for arguments, and read `PLAN.md` before your first plan file. A storyboard is `democut storyboard`'s sheets, shown as images. For an edit of existing footage it never invents scenes: every real cut or one continuous take, stills of the planned look or labelled raw, and every caption line. A face cam over a recording is a layer (`democut help layer.add`).

Always, whatever the instructions' version:

- Record in Chrome or Safari, never in an app's built-in preview.
- Once per take in another browser (never in DemoCut's own, which does it), run `democut overlay hide`'s script before it and `democut overlay show`'s after, not around each click.
  A browser tool that only reads the page (Codex) can't: never open DevTools; use `democut cursor mark`.
- See and hear with DemoCut's own commands (`democut frames`, `loudness`, `transcript`, `probe`), not other tools.
- Ask before replacing an existing file, and never delete the user's media.
- The delivery message relays the export's `notice` if you haven't yet, says which voice narrated (`narration.spoken`), and offers further edits.
