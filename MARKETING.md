# Memory Maker — Communication Kit

Everything you need to explain, demo, and promote Memory Maker. Pull from this for posts, talks, the repo, or a landing page. Written so you can copy-paste and lightly edit in your own voice.

---

## 1. The one-liner (your elevator pitch)

> **Memory Maker gives Claude Code a memory that works on its own.** It quietly remembers what matters from every coding session — your preferences, your decisions, the lessons learned — and brings them back the next time, without you ever asking it to.

Shorter, for a bio or tagline:

> **Autonomous memory for Claude Code. It just remembers.**

---

## 2. The problem (lead with the pain)

Anyone who uses an AI coding assistant has felt this:

- You have a great session. You correct the AI, you make decisions, you establish how you like things done.
- You close the terminal.
- Next session, it's a stranger again. Same mistakes. Same explanations. You start from zero.

The tools *can* remember — but only if you stop, think, and say *"save this to memory."* Nobody does that consistently. The friction kills it. **The best context from your work evaporates the moment you close the window.**

That's the hook. Everyone in your audience has lived it.

---

## 3. What it does (plain English)

Memory Maker runs invisibly in the background of every Claude Code session and does two things:

1. **At the start of every session,** it hands Claude a short index of everything it knows about you and your projects — and tells it to keep an eye out for anything new worth keeping.
2. **At the end of every session,** it reads back over the conversation, pulls out the handful of things genuinely worth remembering, and files them away. Next time, they're already in the room.

No buttons. No "remember this." No ritual. You work; it remembers.

And because the memory is just a folder of plain text files synced through a private git repo, **it follows you everywhere** — laptop, work machine, anywhere you run Claude Code.

---

## 4. How it works (for the technical crowd)

This is the version for developers — it earns credibility because the design is clean.

Memory Maker is a **Claude Code plugin** built on two lifecycle hooks:

- **`SessionStart` hook** injects a memory *index* into the model's context, plus a standing protocol: *if you learn something durable this session — a preference, a correction, a project decision — save it without being asked.* So capture happens live, mid-conversation, not just at the end.

- **`SessionEnd` hook** fires when you exit. It condenses the transcript (strips out tool noise, keeps the actual conversation), then **spawns a detached, headless `claude -p` run using the cheap, fast Haiku model** to act as a "memory distiller." That worker reads the session, decides what's worth keeping, and writes it to disk. Crucially, it's *detached* — your exit is instant, the distillation happens after you're gone.

The store itself is dead simple and portable:

```
~/.memory-maker/
├── MEMORY.md        # the index, injected every session
└── memories/        # one markdown file per fact
```

Each memory is a small markdown file with frontmatter (`type: user | feedback | project | reference`). Because it's **just git**, cross-machine sync is free: pull on session start, push after extraction. Install it anywhere with two commands — the repo doubles as its own plugin marketplace.

**Design decisions worth calling out:**
- *Cheap by default* — Haiku does the distilling; trivial sessions (under two real exchanges) are skipped entirely, so cost is a fraction of a cent per session.
- *Non-blocking* — the extraction is fully detached; it never slows you down.
- *Conservative* — the distiller is prompted to prefer a few high-value memories over noise, and to update existing memories instead of duplicating.
- *Yours* — plain text, local-first, private git. No SaaS lock-in, no black box.

---

## 5. The bigger story (why this matters — your POV)

This is the part that makes it *content* and not just a tool announcement. Your authentic angle:

> Memory is the missing piece of AI-assisted development. We've gotten very good at giving AI *context* — files, docs, instructions. But context you have to re-supply every time isn't really the AI's; it's yours, on loan. Real partnership needs *persistence* — the assistant accumulating an understanding of you and your work over time, the way a human collaborator would.
>
> I built Memory Maker to scratch my own itch first. I do a lot of good work with Claude and I was tired of watching the best parts disappear. Now it just keeps them. I'm sharing it because I think autonomous memory is going to be table stakes for how we all develop with AI — and the sooner more people have it, the better the whole practice gets.

That "build for myself, then help others" framing is genuine and it resonates — it's the maker's story.

---

## 6. Ready-to-post copy

### LinkedIn (your primary channel as an educator)

> I kept losing the best parts of my work with AI.
>
> Every great session with Claude Code — the preferences I'd set, the decisions we'd made, the lessons learned — vanished the second I closed the terminal. The tools *can* remember, but only if you stop and explicitly say "save this." Nobody does that consistently. The friction kills it.
>
> So I built **Memory Maker** — a plugin that gives Claude Code an autonomous memory.
>
> It runs in the background of every session. It quietly remembers what matters and brings it back next time. No buttons, no "remember this" ritual. You work; it remembers. And because the memory is just plain text in a private git repo, it follows you across every machine.
>
> Under the hood it's two lifecycle hooks: one injects what it knows at the start of a session, the other spins up a cheap background model to distill the conversation into durable memories when you exit — without ever slowing you down.
>
> I built it to scratch my own itch. I'm sharing it because I think autonomous memory is going to be table stakes for developing with AI.
>
> [link] — install in two commands.
>
> #AI #ClaudeCode #DeveloperTools #AIAssistedDevelopment

### X / Twitter (thread)

> 1/ I built a plugin that gives Claude Code a memory that works on its own.
>
> No "save this to memory." No ritual. It just remembers what matters from every session and brings it back next time.
>
> Meet Memory Maker 🧠👇

> 2/ The problem: every great AI coding session ends the same way. You close the terminal and all the context — your preferences, your decisions, the lessons — is gone. The AI is a stranger again next time.

> 3/ Memory Maker fixes it with two hooks:
>
> → Session start: it hands Claude everything it knows about you
> → Session end: a cheap background model reads the conversation and files away what's worth keeping
>
> All invisible. Never slows you down.

> 4/ The memory is just markdown files in a private git repo. So it's:
> • portable (every machine)
> • private (yours, local-first)
> • no black box, no SaaS lock-in

> 5/ I built it for myself first — tired of watching the best parts of my work disappear. Sharing it because autonomous memory is going to be how we all develop with AI.
>
> Two commands to install: [link]

### Short blurb (repo header, dev.to intro, newsletter)

> **Memory Maker** is autonomous, cross-session memory for Claude Code. It recalls what it knows at the start of every session and distills new memories from your work at the end — no prompting, no ritual. The store is plain markdown in a private git repo, so it's portable across every machine and entirely yours. Install in two commands.

---

## 7. The demo (this sells it better than any copy)

A 30–60 second screen recording beats every paragraph above. Suggested flow:

1. **Session 1:** Tell Claude something personal — *"I always want my Python formatted with Black, and I prefer pytest over unittest."* Then exit.
2. **Cut to the memory file** appearing in `~/.memory-maker/memories/` — the thing it saved, on its own.
3. **Session 2 (fresh terminal):** Ask it to write a quick test. It uses pytest and Black formatting **without being told.** "I never reminded it. It just knew."

That "it just knew" moment is the whole pitch. Lead your launch with that clip.

---

## 8. Where to post

- **LinkedIn** — your strongest audience as a Pluralsight instructor; the long-form post above.
- **X/Twitter** — the thread + demo clip; tag the dev-tools / AI-builder community.
- **dev.to or a personal blog** — the "how it works" section (#4) makes a great technical write-up; developers love a clean architecture story.
- **GitHub** — README is your landing page; the demo gif at the top.
- **A short YouTube/Loom** — you're an instructor; a 3-minute "here's how I built it and how to install it" plays directly to your strengths and doubles as course-style content.

---

## 9. If you productize it later

The honest current boundary: plugins run in **Claude Code** (CLI, desktop, IDEs), not in claude.ai web/mobile chat. The natural paid/SaaS version is a **hosted memory service** — a remote MCP server fronting the store — so your memory follows you into claude.ai and any other AI surface too. That's the upgrade story when you're ready: *"the open plugin remembers your coding; the service remembers you everywhere."*
