#!/bin/bash
# SessionEnd hook: stage a condensed transcript, then hand off to a detached
# background worker so exiting Claude Code is never delayed.
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MEM_DIR="${MEMORY_MAKER_DIR:-$HOME/.memory-maker}"

if [ "${MEMORY_MAKER_ACTIVE:-0}" = "1" ] || [ -f "$MEM_DIR/paused" ]; then
  exit 0
fi

TRANSCRIPT=$(python3 -c 'import sys,json; print(json.load(sys.stdin).get("transcript_path",""))' 2>/dev/null)
[ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] || exit 0

mkdir -p "$MEM_DIR/memories" "$MEM_DIR/.staging" "$MEM_DIR/logs"

STAGE="$MEM_DIR/.staging/$(date +%Y%m%d-%H%M%S)-$$.md"
if ! python3 "$SCRIPT_DIR/condense.py" "$TRANSCRIPT" > "$STAGE" 2>>"$MEM_DIR/logs/extract.log" || [ ! -s "$STAGE" ]; then
  rm -f "$STAGE"
  exit 0
fi

nohup "$SCRIPT_DIR/extract-worker.sh" >> "$MEM_DIR/logs/extract.log" 2>&1 &
exit 0
