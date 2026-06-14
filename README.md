# Memory Maker

Autonomous, portable, cross-session memory for Claude Code. No more asking Claude to remember things — it just does.

## How it works

Two hooks, one store:

1. **SessionStart** (`scripts/recall.sh`) — injects your memory index into every session's context, plus a protocol telling Claude to *proactively* save durable facts mid-session (preferences, corrections, project decisions) without being asked.
2. **SessionEnd** (`scripts/extract.sh` → `extract-worker.sh`) — when you exit a session, the transcript is condensed (tool noise stripped) and a detached background `claude -p --model haiku` run distills it into memory files. Your exit is never delayed; the worker runs after you're gone.

The store lives at `~/.memory-maker` (override with `MEMORY_MAKER_DIR`):

```
~/.memory-maker/
├── MEMORY.md          # index — one line per memory, injected each session
├── memories/          # one markdown file per fact
├── .staging/          # condensed transcripts awaiting extraction
└── logs/extract.log
```

Memory file format:

```markdown
---
name: kebab-slug
description: one-line summary
type: user | feedback | project | reference
---

The fact, with why it matters.
```

## Install

```
/plugin marketplace add dave-melillo/memory-maker   # or a local path
/plugin install memory-maker@memory-maker
```

That's it. It works in every Claude Code session on that machine (CLI, desktop app, IDE extensions).

## Cross-machine sync

The store is a plain git repo. Run the `memory-maker` skill and ask for `setup-sync`, or manually:

```bash
cd ~/.memory-maker
git init && git add -A && git commit -m "init"
gh repo create memory-maker-store --private --source . --push
```

On every other machine: clone the store repo to `~/.memory-maker`, install the plugin. SessionStart pulls, the extraction worker pushes. **Keep that repo private — it's your personal data.** (This is your *memory store* repo — separate from this public plugin repo.)

## Managing it

In any session: "memory maker status", "search my memories for X", "remember that ...", "pause memory maker". The bundled skill handles all of it. Hard kill switch: `touch ~/.memory-maker/paused`.

## Scope & cost

- Works in **Claude Code** everywhere (CLI, desktop, IDEs, cloud sessions with the plugin installed). Does **not** reach claude.ai web/mobile chat — plugins don't load there. The roadmap for that: serve the store through a remote MCP server and add it as a claude.ai connector.
- Each session exit costs one short Haiku run (typically a fraction of a cent). Trivial sessions (fewer than 2 real user messages) are skipped entirely.

## License

MIT
