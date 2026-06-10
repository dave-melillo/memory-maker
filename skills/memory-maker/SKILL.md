---
name: memory-maker
description: Manage the Memory Maker store — show status, search memories, save one manually, set up cross-machine git sync, or pause/resume autonomous capture. Use when the user asks about their persistent memories or wants to configure Memory Maker.
---

# Memory Maker management

The memory store lives at `$MEMORY_MAKER_DIR` if set, otherwise `~/.memory-maker`:

- `memories/*.md` — one file per memory (frontmatter: name, description, type)
- `MEMORY.md` — index, one line per memory
- `.staging/` — condensed transcripts awaiting extraction
- `logs/extract.log` — extraction worker log
- `paused` — if this file exists, all hooks are disabled

Figure out which operation the user wants and do it:

## status
Report: number of memories (`ls memories/*.md | wc -l`), the index contents, any pending `.staging/` files, last lines of `logs/extract.log`, whether the store is a git repo with a remote, and whether `paused` exists.

## search <query>
Grep `memories/` for the query and summarize matching memories.

## save <fact>
Write the memory file and index line yourself, following the format in this plugin's README (frontmatter name/description/type, then the fact). Then commit if the store is a git repo.

## setup-sync
Cross-machine sync uses a **private** git repo:
1. `cd` to the store; `git init` if needed; create `.gitignore` containing `.staging/`, `logs/`, `.lock`.
2. Ask the user for a private repo (suggest `gh repo create memory-maker-store --private` if `gh` is available).
3. `git remote add origin <url>`, commit everything, push with `-u origin main`.
On a second machine: clone the repo to `~/.memory-maker` before first use. Warn the user: memories are personal data — the repo must stay private.

## pause / resume
`touch` or `rm` the `paused` file in the store.
