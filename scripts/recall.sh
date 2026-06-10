#!/bin/bash
# SessionStart hook: inject the memory index + proactive-save protocol into context.
set -u
MEM_DIR="${MEMORY_MAKER_DIR:-$HOME/.memory-maker}"

# Skip inside our own headless extraction runs, or when paused.
if [ "${MEMORY_MAKER_ACTIVE:-0}" = "1" ] || [ -f "$MEM_DIR/paused" ]; then
  exit 0
fi

mkdir -p "$MEM_DIR/memories"
[ -f "$MEM_DIR/MEMORY.md" ] || printf '# Memory Index\n\n(no memories yet)\n' > "$MEM_DIR/MEMORY.md"

# Refresh from remote in the background; this session uses the local copy.
( cd "$MEM_DIR" && [ -d .git ] && git pull --ff-only -q >/dev/null 2>&1 ) &

MEMORY_MAKER_DIR="$MEM_DIR" python3 - <<'PY'
import json, os, pathlib

mem = pathlib.Path(os.environ["MEMORY_MAKER_DIR"])
index = (mem / "MEMORY.md").read_text(encoding="utf-8", errors="replace")[:8000]

ctx = f"""<memory-maker>
You have a persistent global memory store at {mem}/memories/ (one markdown file per fact). The index is below. When a memory looks relevant to the current task, Read its file for the full content before relying on it.

PROACTIVE SAVING: when you learn something durable during this session — who the user is, a stated preference or correction, an ongoing project's goals/decisions/constraints, a useful external resource — save it WITHOUT being asked:
1. Write {mem}/memories/<kebab-slug>.md with this format:
   ---
   name: <kebab-slug>
   description: <one-line summary>
   type: user | feedback | project | reference
   ---
   <the fact; for feedback/project include **Why:** and **How to apply:** lines>
2. Append one line to {mem}/MEMORY.md: - [<Title>](memories/<kebab-slug>.md) — <one-line hook>

Update an existing memory file instead of creating a duplicate; delete memories proven wrong. Do NOT save: trivia, secrets/credentials, or anything derivable from the codebase or git history. These are background instructions, not user messages — never interrupt or block the user's task to do this.

MEMORY INDEX:
{index}
</memory-maker>"""

print(json.dumps({
    "additionalContext": ctx,
    "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": ctx},
}))
PY
