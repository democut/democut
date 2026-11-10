#!/bin/bash
# DemoCut installer: curl -fsSL https://democut.app/install.sh | bash
#
# Installs DemoCut (a Mac screen recorder and editor that agents drive from the terminal) on an
# Apple silicon Mac with macOS 15 or later, links its democut command at ~/.local/bin/democut, and
# adds the DemoCut skill to Claude Code (~/.claude) and Codex (~/.codex) when their folder exists,
# with the app's own `democut setup --skills` (an older DemoCut without it is skipped quietly). No
# agent folder is created and a skill the user edited is kept. Opt out with --no-skills or
# DEMOCUT_INSTALL_NO_SKILLS=1. Adding the skill never fails the install.
# It checks the download before installing: the disk image's and the app's Developer ID signature
# (Team ID Z397P55TUW), Apple's notarization, the bundle id and the version. Any mismatch stops it
# with nothing installed. It never uses sudo, never downgrades, never replaces a DemoCut that is
# open, and never touches projects or other data.
#
# Exit codes: 0 done (or nothing to do), 1 failed (network, disk), 2 usage, 3 this Mac can't run
# DemoCut or DemoCut is open (fix it, run again), 4 the download failed verification (refused).
#
# Testing overrides (not for users): DEMOCUT_INSTALL_DIR (install there and look for an existing
# copy only there), DEMOCUT_INSTALL_DMG (verify and install this local disk image instead of
# downloading one), DEMOCUT_INSTALL_BASE_URL (an https origin in place of https://democut.app),
# DEMOCUT_INSTALL_INTERNAL=1 (DemoCut staff only: marks the requests as internal traffic).
#
# Everything is in functions and `main` runs on the last line, so a partial download runs nothing.
# bash 3.2 compatible (the bash macOS ships).
set -euo pipefail

SCRIPT_VERSION="1.0.0"
TEAM_ID="Z397P55TUW"
BUNDLE_ID="app.screencap.desktop"
APP_NAME="DemoCut.app"
CLI_PATH_IN_APP="Contents/Resources/bin/democut"
LINK_IN_HOME=".local/bin/democut"
MIN_MACOS=15
# Developer ID (leaf and intermediate markers) from our team, the app's identifier included.
DEVELOPER_ID='anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] exists and certificate leaf[field.1.2.840.113635.100.6.1.13] exists and certificate leaf[subject.OU] = "Z397P55TUW"'
APP_REQUIREMENT="$DEVELOPER_ID and identifier \"$BUNDLE_ID\""
CLI_REQUIREMENT="$DEVELOPER_ID and identifier \"democut\""

VERSION_PATTERN='^[0-9]+(\.[0-9]+){0,3}$'
URL_PATTERN='^https://[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9._~%+-]+)+$'

DRY_RUN=0
NO_SKILLS=0
WORK=""
MOUNT=""
STAGING=""
# While an upgrade swaps bundles: the old one moved aside, and where it goes back.
OLD_APP=""
OLD_TARGET=""

say() { printf '%s\n' "$*"; }
warn() { printf 'democut-install: %s\n' "$*" >&2; }
# die <exit code> <message…>
die() {
  local code="$1"
  shift
  warn "$*"
  exit "$code"
}

usage() {
  cat <<'EOF'
DemoCut installer: installs DemoCut and links the democut command for coding agents.

  curl -fsSL https://democut.app/install.sh | bash
  curl -fsSL https://democut.app/install.sh | bash -s -- --dry-run

Options:
  --dry-run    Check this Mac and the current release, and report what it would do. Writes
               nothing and downloads no installer.
  --no-skills  Don't add the DemoCut skill to Claude Code or Codex.
               DEMOCUT_INSTALL_NO_SKILLS=1 does the same.
  --version    Print the installer's version.
  --help       Print this help.

The DemoCut skill goes to each coding agent whose folder exists (~/.claude for Claude Code,
~/.codex for Codex). A skill you edited is kept.

It needs an Apple silicon Mac with macOS 15 or later, and installs to /Applications (or
~/Applications when /Applications isn't writable) without sudo. The download is checked before
anything is installed: its Developer ID signature (Team ID Z397P55TUW), Apple's notarization,
the app's bundle id and its version. A newer or equal DemoCut already installed is kept.

Exit codes: 0 done, 1 failed, 2 usage, 3 not supported here or DemoCut is open, 4 the download
failed verification (refused).
EOF
}

# --- Pure helpers (no side effects; tested on Linux too) -------------------------------------

version_valid() { [[ "$1" =~ $VERSION_PATTERN ]]; }

# version_cmp A B prints -1, 0 or 1 (A older, equal, newer), comparing dotted numbers.
version_cmp() {
  local a="$1" b="$2" i x y
  local -a pa pb
  IFS=. read -r -a pa <<<"$a"
  IFS=. read -r -a pb <<<"$b"
  for ((i = 0; i < 4; i++)); do
    x="${pa[i]:-0}"
    y="${pb[i]:-0}"
    if ((10#$x < 10#$y)); then
      echo -1
      return
    elif ((10#$x > 10#$y)); then
      echo 1
      return
    fi
  done
  echo 0
}

# platform_problem OS ARCH MACOS_VERSION prints why DemoCut can't run here (and returns 1), or
# prints nothing (and returns 0).
platform_problem() {
  local os="$1" arch="$2" macos="$3" major
  if [ "$os" != "Darwin" ]; then
    echo "DemoCut runs on macOS only (this is $os)."
    return 1
  fi
  if [ "$arch" != "arm64" ]; then
    echo "DemoCut needs a Mac with Apple silicon (M1 or later); this Mac is $arch."
    return 1
  fi
  major="${macos%%.*}"
  if ! [[ "$major" =~ ^[0-9]+$ ]] || ((10#$major < MIN_MACOS)); then
    echo "DemoCut needs macOS $MIN_MACOS or later; this Mac has macOS $macos. Update macOS in System Settings > General > Software Update, then run this again."
    return 1
  fi
  return 0
}

# release_problem URL VERSION prints what is wrong with a release description (returns 1), or
# nothing (returns 0). The file must be the notarized arm64 disk image of that version.
release_problem() {
  local url="$1" version="$2"
  if ! version_valid "$version"; then
    echo "The release's version ($version) isn't a version number."
    return 1
  fi
  if ! [[ "$url" =~ $URL_PATTERN ]]; then
    echo "The release's download address ($url) isn't an https address."
    return 1
  fi
  if [ "${url##*/}" != "$(expected_file "$version")" ]; then
    echo "The release's file (${url##*/}) isn't $(expected_file "$version")."
    return 1
  fi
  return 0
}

expected_file() { printf 'DemoCut-%s-macOS-arm64-notarized.dmg' "$1"; }

# plan_action INSTALLED AVAILABLE prints install (nothing there), upgrade, current or newer.
plan_action() {
  local installed="$1" available="$2"
  if [ -z "$installed" ]; then
    echo install
    return
  fi
  case "$(version_cmp "$installed" "$available")" in
    -1) echo upgrade ;;
    0) echo current ;;
    *) echo newer ;;
  esac
}

# A path as a shell word: bare when it is plain, else single-quoted.
shell_quote() {
  if [[ "$1" =~ ^[A-Za-z0-9_./+-]+$ ]]; then
    printf '%s' "$1"
  else
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
  fi
}

# on_path DIR PATH: whether DIR is one of PATH's folders.
on_path() {
  case ":$2:" in
  *":$1:"* | *":$1/:"*) return 0 ;;
  *) return 1 ;;
  esac
}

# Whether a link target is DemoCut's command (any copy of the app), the app's own rule.
ours_target() { case "$1" in */Resources/bin/democut) return 0 ;; *) return 1 ;; esac }

# skill_agents HOME: the coding agents whose folder exists in HOME, as democut setup names them
# (claude for ~/.claude, codex for ~/.codex), comma-separated; empty when neither does.
skill_agents() {
  local ids=""
  if [ -d "$1/.claude" ]; then ids=claude; fi
  if [ -d "$1/.codex" ]; then ids="${ids:+$ids,}codex"; fi
  printf '%s' "$ids"
}

# agent_names IDS: those agents by name.
agent_names() {
  case "$1" in
  claude) printf 'Claude Code' ;;
  codex) printf 'Codex' ;;
  *) printf 'Claude Code and Codex' ;;
  esac
}

# --- macOS helpers ---------------------------------------------------------------------------

# json_field KEY: the string at KEY in the JSON on stdin. plutil reads JSON on every supported
# macOS; nothing downloaded is ever evaluated.
json_field() { plutil -extract "$1" raw -o - - 2>/dev/null; }

plist_field() { plutil -extract "$2" raw -o - "$1/Contents/Info.plist" 2>/dev/null; }

# installed_version APP prints the version of DemoCut at APP (returns 0), returns 1 when nothing
# is there, and 2 when another app holds the name.
installed_version() {
  local app="$1" id version
  [ -e "$app" ] || return 1
  id="$(plist_field "$app" CFBundleIdentifier || true)"
  [ "$id" = "$BUNDLE_ID" ] || return 2
  version="$(plist_field "$app" CFBundleShortVersionString || true)"
  version_valid "$version" || return 2
  printf '%s' "$version"
}

# Whether a process runs from inside APP (DemoCut itself, its headless engine or its command).
app_in_use() {
  local app="$1" procs line
  # Listed first, then matched, so no matcher process counts itself.
  procs="$(ps -axo command= 2>/dev/null || true)"
  while IFS= read -r line; do
    case "$line" in "$app/Contents/"*) return 0 ;; esac
  done <<<"$procs"
  return 1
}

# verify_dmg FILE: Developer ID from our team, and Gatekeeper accepts it as notarized.
verify_dmg() {
  local dmg="$1" out
  if ! out="$(codesign --verify --strict -R="$DEVELOPER_ID" "$dmg" 2>&1)"; then
    die 4 "Refused: the disk image isn't signed by DemoCut's developer, Team ID $TEAM_ID ($(reason "$out" "$dmg")). Nothing was installed."
  fi
  out="$(spctl -a -t open --context context:primary-signature -vv "$dmg" 2>&1)" ||
    die 4 "Refused: Gatekeeper rejects the disk image ($(reason "$out" "$dmg")). Nothing was installed."
  gatekeeper_ok "$out" "the disk image"
}

# reason OUTPUT PATH: a tool's first line, without the path it starts with.
reason() {
  local line
  line="$(printf '%s\n' "$1" | head -n 1)"
  line="${line#"$2": }"
  printf '%s' "${line:-no detail}"
}

# gatekeeper_ok SPCTL_OUTPUT WHAT: the assessment came from notarization by our team.
gatekeeper_ok() {
  local out="$1" what="$2"
  case "$out" in
  *"override=security disabled"*)
    die 4 "Refused: Gatekeeper is turned off on this Mac, so $what's notarization can't be confirmed. Nothing was installed."
    ;;
  esac
  case "$out" in
  *"source=Notarized Developer ID"*) ;;
  *) die 4 "Refused: $what isn't notarized by Apple ($(printf '%s' "$out" | grep '^source=' || echo 'no source')). Nothing was installed." ;;
  esac
  case "$out" in
  *"origin=Developer ID Application:"*"($TEAM_ID)"*) ;;
  *) die 4 "Refused: $what isn't from DemoCut's developer (Team ID $TEAM_ID). Nothing was installed." ;;
  esac
}

# verify_app APP VERSION: the whole bundle is intact and signed by our team, Gatekeeper accepts it
# as notarized, and it is DemoCut VERSION with its command inside.
#
# Notarization: `spctl -a -t exec` is Gatekeeper's own verdict, and it reports
# source=Notarized Developer ID only for a notarized app (with the stapled ticket, or Apple's
# ticket online). `stapler validate` isn't used: on a Mac without Xcode, /usr/bin/stapler and
# xcrun are developer-tool shims that fail or offer to install the tools. codesign shows whether
# the ticket is stapled (needed only to open the app offline the first time); that is reported.
verify_app() {
  local app="$1" version="$2" out id team got
  [ -d "$app" ] || die 4 "Refused: the disk image has no $APP_NAME. Nothing was installed."
  if ! out="$(codesign --verify --deep --strict -R="$APP_REQUIREMENT" "$app" 2>&1)"; then
    die 4 "Refused: $APP_NAME's signature doesn't verify ($(reason "$out" "$app")). It was changed after signing, or isn't DemoCut's. Nothing was installed."
  fi
  out="$(codesign -dvvv "$app" 2>&1)" || die 4 "Refused: can't read $APP_NAME's signature. Nothing was installed."
  id="$(printf '%s\n' "$out" | sed -n 's/^Identifier=//p' | head -n 1)"
  team="$(printf '%s\n' "$out" | sed -n 's/^TeamIdentifier=//p' | head -n 1)"
  [ "$id" = "$BUNDLE_ID" ] || die 4 "Refused: $APP_NAME's identifier is $id, not $BUNDLE_ID. Nothing was installed."
  [ "$team" = "$TEAM_ID" ] || die 4 "Refused: $APP_NAME's Team ID is $team, not $TEAM_ID. Nothing was installed."
  case "$out" in
  *"Notarization Ticket=stapled"*) STAPLED=1 ;;
  *) STAPLED=0 ;;
  esac
  out="$(spctl -a -t exec -vv "$app" 2>&1)" ||
    die 4 "Refused: Gatekeeper rejects $APP_NAME ($(reason "$out" "$app")). Nothing was installed."
  gatekeeper_ok "$out" "$APP_NAME"
  got="$(plist_field "$app" CFBundleIdentifier || true)"
  [ "$got" = "$BUNDLE_ID" ] || die 4 "Refused: $APP_NAME's bundle id is $got, not $BUNDLE_ID. Nothing was installed."
  got="$(plist_field "$app" CFBundleShortVersionString || true)"
  [ "$got" = "$version" ] || die 4 "Refused: $APP_NAME is version $got, but the current release is $version. Nothing was installed."
  [ -x "$app/$CLI_PATH_IN_APP" ] || die 4 "Refused: $APP_NAME has no democut command. Nothing was installed."
  codesign --verify --strict -R="$CLI_REQUIREMENT" "$app/$CLI_PATH_IN_APP" >/dev/null 2>&1 ||
    die 4 "Refused: the democut command inside $APP_NAME isn't signed by DemoCut's developer. Nothing was installed."
}

# curl with the installer's user agent (and the internal mark for DemoCut staff).
fetch() {
  local agent="democut-install/$SCRIPT_VERSION (macOS $MACOS; $ARCH)"
  if [ "${DEMOCUT_INSTALL_INTERNAL:-}" = 1 ]; then
    curl --proto '=https' --proto-redir '=https' --tlsv1.2 --connect-timeout 15 -A "$agent" \
      -H 'X-DemoCut-Internal: 1' "$@"
  else
    curl --proto '=https' --proto-redir '=https' --tlsv1.2 --connect-timeout 15 -A "$agent" "$@"
  fi
}

offline() {
  die 1 "Couldn't download from $1 (curl exit $2). Check the internet connection and run this again. Nothing was installed."
}

cleanup() {
  local code=$?
  set +e
  # Interrupted between the two renames of an upgrade: put the old DemoCut back.
  if [ -n "$OLD_APP" ] && [ -e "$OLD_APP" ] && [ ! -e "$OLD_TARGET" ]; then
    mv "$OLD_APP" "$OLD_TARGET" && warn "Interrupted: the previous DemoCut is back at $OLD_TARGET."
  fi
  if [ -n "$STAGING" ] && [ -e "$STAGING" ]; then rm -rf "$STAGING"; fi
  if [ -n "$MOUNT" ]; then
    if ! hdiutil detach "$MOUNT" -quiet >/dev/null 2>&1; then
      sleep 1
      hdiutil detach "$MOUNT" -force -quiet >/dev/null 2>&1 ||
        warn "Couldn't eject the DemoCut disk image at $MOUNT; eject it in Finder."
    fi
  fi
  # Only once nothing is mounted inside it.
  if [ -n "$WORK" ] && [ -d "$WORK" ] && ! mount | grep -F -q " on $WORK/"; then rm -rf "$WORK"; fi
  exit "$code"
}

# link_command CLI: points ~/.local/bin/democut at CLI, replacing only DemoCut's own link. Sets
# COMMAND to what to run.
link_command() {
  local cli="$1" link="$HOME/$LINK_IN_HOME" current temporary
  COMMAND="$(shell_quote "$cli")"
  if [ -L "$link" ]; then
    current="$(readlink "$link")"
    if [ "$current" = "$cli" ]; then
      say "The democut command is linked: $link -> $cli"
      COMMAND="$(shell_quote "$link")"
      return
    fi
    if ! ours_target "$current"; then
      warn "$link links to $current, not DemoCut; left as it is. Run DemoCut's command by its full path."
      return
    fi
  elif [ -e "$link" ]; then
    warn "$link exists and isn't DemoCut's link; left as it is. Run DemoCut's command by its full path."
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    say "Would link $link -> $cli"
    COMMAND="$(shell_quote "$link")"
    return
  fi
  mkdir -p "$(dirname "$link")"
  temporary="$(dirname "$link")/.democut.$$.tmp"
  ln -s "$cli" "$temporary"
  if ! mv -f "$temporary" "$link"; then
    rm -f "$temporary"
    warn "Couldn't link $link; run DemoCut's command by its full path."
    return
  fi
  say "Linked the democut command: $link -> $cli"
  COMMAND="$(shell_quote "$link")"
}

# add_skills CLI COMMAND: adds the DemoCut skill to each coding agent whose folder exists, with the
# command's own `setup --skills` (the app's rules: no agent folder is created, a skill the user
# edited is kept). Skipped with --no-skills, when no agent folder exists, and quietly for an
# older DemoCut whose command has no setup. A failure only warns: DemoCut is installed either
# way. COMMAND is how the user runs democut (bare when on PATH). Sets SKILLS=1 when the skill
# is (or, in a dry run, would be) set up.
add_skills() {
  local cli="$1" run="${2:-democut}" ids out
  SKILLS=0
  if [ "$NO_SKILLS" = 1 ] || [ "${DEMOCUT_INSTALL_NO_SKILLS:-}" = 1 ]; then
    say "Skipped the DemoCut skill, as asked."
    return 0
  fi
  ids="$(skill_agents "$HOME")"
  if [ -z "$ids" ]; then
    say "No Claude Code or Codex found, so the DemoCut skill wasn't installed. After you install one, run: $run setup --skills claude,codex"
    return 0
  fi
  # A dry run of a new install: the command isn't there yet.
  if [ "$DRY_RUN" = 1 ] && [ ! -x "$cli" ]; then
    say "Would add the DemoCut skill for $(agent_names "$ids")."
    SKILLS=1
    return 0
  fi
  # An older DemoCut's command has no setup (help exits 2): skipped without a word.
  "$cli" help setup >/dev/null 2>&1 || return 0
  if [ "$DRY_RUN" = 1 ]; then
    if ! out="$("$cli" setup --skills "$ids" --dry-run 2>&1)"; then
      warn "Couldn't check the DemoCut skill: $(printf '%s\n' "$out" | head -n 1)"
      return 0
    fi
  elif ! out="$("$cli" setup --skills "$ids" 2>&1)"; then
    warn "Couldn't add the DemoCut skill: $(printf '%s\n' "$out" | head -n 1) DemoCut is installed; to add the skill, open DemoCut and choose Settings > Agents."
    return 0
  fi
  printf '%s\n' "$out"
  SKILLS=1
}

next_steps() {
  local cli="$1" command linked=0
  link_command "$cli"
  command="$COMMAND"
  if [ "$command" = "$(shell_quote "$HOME/$LINK_IN_HOME")" ]; then linked=1; fi
  if [ "$linked" = 1 ] && on_path "$HOME/.local/bin" "${PATH:-}"; then
    command=democut
    say "$HOME/.local/bin is on your PATH."
  elif [ "$linked" = 1 ]; then
    say "$HOME/.local/bin isn't on your PATH, so run the command by its full path (or add it to PATH)."
  fi
  # The skill runs DemoCut by the link, so only once the link is DemoCut's.
  SKILLS=0
  if [ "$linked" = 1 ]; then add_skills "$cli" "$command"; fi
  cat <<EOF

Next, run:
  $command preflight
  $command instructions

preflight asks macOS for the permissions a recording needs and reports any blockers.
instructions is the whole flow for making a video; read it before you plan.

macOS asks the user, not you, for Screen Recording, Accessibility, the camera and microphone,
and access to their folders. When preflight reports a blocker, give the user its fix and wait,
then run preflight again. Never try to get around a permission prompt.
EOF
  if [ "$SKILLS" != 1 ]; then
    cat <<'EOF'

The DemoCut skill is optional: preflight and instructions give an agent everything it needs.
To add it to Claude Code or Codex for good, open DemoCut and choose Settings > Agents.
EOF
  fi
  say ""
  say "To make a video, paste this into your coding agent:"
  say "  $PASTE_LINE"
}

main() {
  local arg
  for arg in "$@"; do
    case "$arg" in
    -h | --help)
      usage
      return 0
      ;;
    -V | --version)
      say "democut-install $SCRIPT_VERSION"
      return 0
      ;;
    -n | --dry-run) DRY_RUN=1 ;;
    --no-skills) NO_SKILLS=1 ;;
    *)
      warn "Unknown option: $arg"
      usage >&2
      exit 2
      ;;
    esac
  done

  local os problem
  os="$(uname -s)"
  ARCH="$(uname -m)"
  MACOS=""
  if [ "$os" = Darwin ]; then
    MACOS="$(sw_vers -productVersion 2>/dev/null || echo 0)"
    # A shell under Rosetta reports x86_64 on Apple silicon.
    if [ "$ARCH" = x86_64 ] && [ "$(sysctl -n hw.optional.arm64 2>/dev/null || true)" = 1 ]; then ARCH=arm64; fi
  fi
  if ! problem="$(platform_problem "$os" "$ARCH" "$MACOS")"; then die 3 "$problem"; fi
  if [ "$(id -u)" = 0 ]; then die 3 "Run this as yourself, without sudo: DemoCut installs for your user."; fi
  [ -n "${HOME:-}" ] && [ -d "$HOME" ] || die 1 "HOME isn't a folder."

  local base="${DEMOCUT_INSTALL_BASE_URL:-https://democut.app}"
  base="${base%/}"
  [[ "$base" =~ ^https://[A-Za-z0-9.-]+(:[0-9]+)?$ ]] || die 2 "DEMOCUT_INSTALL_BASE_URL must be an https origin."

  # The current release: its version and file.
  local release code url version
  release="$(fetch -fsS --max-time 60 "$base/download.json" 2>/dev/null)" || offline "$base" "$?"
  url="$(printf '%s' "$release" | json_field url || true)"
  version="$(printf '%s' "$release" | json_field version || true)"
  if ! problem="$(release_problem "$url" "$version")"; then
    die 4 "Refused: $base/download.json doesn't describe a DemoCut release. $problem"
  fi
  say "The current DemoCut is $version."

  # What is installed already: in DEMOCUT_INSTALL_DIR alone, else /Applications and ~/Applications.
  local dirs dir app found="" found_version="" status installed
  if [ -n "${DEMOCUT_INSTALL_DIR:-}" ]; then dirs="$DEMOCUT_INSTALL_DIR"; else dirs="/Applications:$HOME/Applications"; fi
  local IFS_SAVE="$IFS"
  IFS=:
  for dir in $dirs; do
    IFS="$IFS_SAVE"
    app="$dir/$APP_NAME"
    status=0
    installed="$(installed_version "$app")" || status=$?
    if [ "$status" = 2 ]; then
      warn "$app isn't DemoCut (bundle id $(plist_field "$app" CFBundleIdentifier || echo unknown)); it is left as it is."
    elif [ "$status" = 0 ] && { [ -z "$found" ] || [ "$(version_cmp "$installed" "$found_version")" = 1 ]; }; then
      found="$app"
      found_version="$installed"
    fi
  done
  IFS="$IFS_SAVE"

  local action
  action="$(plan_action "$found_version" "$version")"
  case "$action" in
  current | newer)
    if [ "$action" = current ]; then
      say "DemoCut $found_version is already installed at $found; nothing to install."
    else
      say "DemoCut $found_version at $found is newer than $version; nothing to install (never downgrades)."
    fi
    # Read-only, so a dry run checks it too: the command is linked only into a verified app.
    verify_app "$found" "$found_version"
    say "Verified it: signature, Team ID $TEAM_ID and notarization."
    next_steps "$found/$CLI_PATH_IN_APP"
    return 0
    ;;
  esac

  # Where to install: beside the copy being upgraded, else DEMOCUT_INSTALL_DIR, /Applications
  # when writable, else ~/Applications.
  local target_dir
  if [ "$action" = upgrade ] && [ -w "$(dirname "$found")" ]; then
    target_dir="$(dirname "$found")"
  elif [ -n "${DEMOCUT_INSTALL_DIR:-}" ]; then
    target_dir="$DEMOCUT_INSTALL_DIR"
  elif [ -w /Applications ]; then
    target_dir=/Applications
  else
    target_dir="$HOME/Applications"
  fi
  local target="$target_dir/$APP_NAME"
  status=0
  installed_version "$target" >/dev/null || status=$?
  if [ "$status" = 2 ]; then
    die 3 "$target is another app, not DemoCut. Move it away, then run this again."
  fi
  if [ -e "$target" ] && app_in_use "$target"; then
    die 3 "DemoCut $found_version is open. Quit DemoCut (or let it update itself when it offers), then run this again."
  fi
  if [ "$action" = upgrade ]; then
    say "DemoCut $found_version at $found will be updated to $version."
  fi

  if [ "$DRY_RUN" = 1 ]; then
    local location
    location="$(fetch -fsS -I --max-time 30 -o /dev/null -w '%{redirect_url}' "$base/dl/mac?via=install" 2>/dev/null)" ||
      offline "$base" "$?"
    [ "$location" = "$url" ] || die 4 "Refused: $base/dl/mac leads to $location, not the release in download.json ($url)."
    say "Would download $url"
    say "Would verify its signature (Team ID $TEAM_ID), notarization, bundle id ($BUNDLE_ID) and version ($version)"
    say "Would install DemoCut $version at $target"
    next_steps "$target/$CLI_PATH_IN_APP"
    return 0
  fi

  WORK="$(mktemp -d "${TMPDIR:-/tmp}/democut-install.XXXXXX")"
  trap cleanup EXIT
  trap 'exit 130' INT TERM
  local dmg
  if [ -n "${DEMOCUT_INSTALL_DMG:-}" ]; then
    dmg="$DEMOCUT_INSTALL_DMG"
    [ -f "$dmg" ] || die 1 "DEMOCUT_INSTALL_DMG ($dmg) isn't a file."
    say "Using the disk image $dmg"
  else
    # The counted download link must lead to the release download.json names.
    local location
    location="$(fetch -fsS --max-time 30 -o /dev/null -w '%{redirect_url}' "$base/dl/mac?via=install" 2>/dev/null)" ||
      offline "$base" "$?"
    [ "$location" = "$url" ] || die 4 "Refused: $base/dl/mac leads to $location, not the release in download.json ($url). Nothing was installed."
    dmg="$WORK/$(expected_file "$version")"
    say "Downloading DemoCut $version (about 200 MB)…"
    code=0
    fetch -fsS -L --retry 2 -o "$dmg" "$location" || code=$?
    [ "$code" = 0 ] || offline "${location%%/updates/*}" "$code"
  fi

  say "Verifying the download…"
  verify_dmg "$dmg"
  MOUNT="$WORK/mount"
  mkdir "$MOUNT"
  if ! hdiutil attach -readonly -nobrowse -noautoopen -mountpoint "$MOUNT" -quiet "$dmg" >/dev/null 2>&1; then
    MOUNT=""
    die 4 "Refused: the disk image doesn't open. Nothing was installed."
  fi
  verify_app "$MOUNT/$APP_NAME" "$version"

  # Copy beside the target, verify the copy, then rename it into place.
  mkdir -p "$target_dir"
  [ -w "$target_dir" ] || die 1 "Can't write to $target_dir."
  STAGING="$target_dir/.DemoCut.app.installing.$$"
  ditto "$MOUNT/$APP_NAME" "$STAGING" || die 1 "Couldn't copy DemoCut to $target_dir."
  verify_app "$STAGING" "$version"
  if [ -e "$target" ]; then
    app_in_use "$target" && die 3 "DemoCut opened while installing. Quit DemoCut, then run this again."
    local old="$target_dir/.DemoCut.app.previous.$$"
    OLD_APP="$old"
    OLD_TARGET="$target"
    mv "$target" "$old" || die 1 "Couldn't move the old DemoCut aside."
    if ! mv "$STAGING" "$target"; then
      mv "$old" "$target"
      die 1 "Couldn't put DemoCut in place; the old one is back."
    fi
    OLD_APP=""
    rm -rf "$old"
  else
    mv "$STAGING" "$target" || die 1 "Couldn't put DemoCut in place."
  fi
  STAGING=""
  say "Installed DemoCut $version at $target (signature, Team ID $TEAM_ID and notarization verified)."
  if [ "$STAPLED" = 0 ]; then
    warn "Its notarization ticket isn't stapled; the first launch needs the internet."
  fi
  next_steps "$target/$CLI_PATH_IN_APP"
}

STAPLED=0
COMMAND=""
SKILLS=0
# The sentence the user pastes into their coding agent once DemoCut is installed.
PASTE_LINE="Make a 30-second demo video of <your app> with DemoCut."
ARCH=""
MACOS=""

# Tests load the functions alone.
# shellcheck disable=SC2317
if [ "${DEMOCUT_INSTALL_LIB:-}" = 1 ]; then return 0 2>/dev/null || exit 0; fi
main "$@" </dev/null
