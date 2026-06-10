#!/bin/bash
# Detached worker: run a small headless Claude (haiku) over staged transcripts
# to distill durable memories, then commit/push the store if it's a git repo.
set -u
MEM_DIR="${MEMORY_MAKER_DIR:-$HOME/.memory-maker}"
export MEMORY_MAKER_ACTIVE=1

# Locate claude — hook environments can have a minimal PATH.
CLAUDE_BIN="$(command -v claude || true)"
if [ -z "$CLAUDE_BIN" ]; then
  for c in "$HOME/.claude/local/claude" "$HOME/.local/bin/claude" /opt/homebrew/bin/claude /usr/local/bin/claude; do
    [ -x "$c" ] && CLAUDE_BIN="$c" && break
  done
fi
[ -n "$CLAUDE_BIN" ] || { echo "[$(date)] claude binary not found, skipping extraction"; exit 1; }

# One worker at a time; staging files a skipped run leaves behind are
# picked up by the next session's worker.
mkdir "$MEM_DIR/.lock" 2>/dev/null || exit 0
trap 'rmdir "$MEM_DIR/.lock" 2>/dev/null' EXIT

cd "$MEM_DIR" || exit 1
[ -d .git ] && git pull --ff-only -q >/dev/null 2>&1

ls .staging/*.md >/dev/null 2>&1 || exit 0

PROMPT=$(cat <<'EOF'
You are a memory distiller. Your cwd is a memory store with memories/ (one markdown file per fact), MEMORY.md (the index), and .staging/ (condensed Claude Code session transcripts). Your job:

1. Read every file in .staging/.
2. Extract only DURABLE facts worth remembering across future sessions:
   - user: who the user is — role, expertise, preferences
   - feedback: corrections or guidance on how the assistant should work (include the why)
   - project: ongoing work, goals, decisions, constraints (convert relative dates to absolute)
   - reference: useful external resources (URLs, dashboards, tickets)
   Skip: code mechanics already recorded in a repo, one-off task details, secrets/credentials, small talk.
3. For each fact, check memories/ for an existing file that already covers it (Glob/Grep). Update that file rather than duplicating; otherwise Write memories/<kebab-slug>.md:
   ---
   name: <kebab-slug>
   description: <one-line summary>
   type: user | feedback | project | reference
   ---
   <the fact; for feedback/project include **Why:** and **How to apply:** lines>
4. Keep MEMORY.md as the index: exactly one line per memory file, format:
   - [Title](memories/<slug>.md) — <one-line hook>
   Add or update lines for whatever you changed.
5. It is fine — common, even — for a session to contain NOTHING worth saving. In that case change no files.

Be conservative: a few high-value memories beat many noisy ones.
EOF
)

if "$CLAUDE_BIN" -p "$PROMPT" \
  --model haiku \
  --allowedTools "Read,Write,Edit,Glob,Grep" \
  --permission-mode acceptEdits \
  --settings '{"disableAllHooks": true}' \
  > "$MEM_DIR/logs/last-extraction.txt" 2>&1; then
  rm -f .staging/*.md
  echo "[$(date)] extraction complete"
else
  echo "[$(date)] extraction failed; staging files kept for next run"
fi

if [ -d .git ]; then
  git add -A >/dev/null 2>&1
  git commit -qm "memory: $(date '+%Y-%m-%d %H:%M')" >/dev/null 2>&1
  if git remote get-url origin >/dev/null 2>&1; then
    git push -q >/dev/null 2>&1 || echo "[$(date)] push failed (offline?); will retry next run"
  fi
fi
exit 0
