#!/usr/bin/env python3
"""Condense a Claude Code transcript (.jsonl) into plain markdown for memory extraction.

Keeps only user/assistant text, drops tool calls/results and system noise,
caps per-message and total size. Exits silently with no output if the
session is too thin to bother extracting from.
"""
import json
import sys

MAX_MSG = 2000
MAX_TOTAL = 60000


def text_of(content):
    if isinstance(content, str):
        return content
    parts = []
    if isinstance(content, list):
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                parts.append(block.get("text", ""))
    return "\n".join(parts)


def main(path):
    out = []
    total = 0
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            if rec.get("type") not in ("user", "assistant"):
                continue
            text = text_of((rec.get("message") or {}).get("content")).strip()
            if not text:
                continue
            if text.startswith("<command-name>") or text.startswith("<local-command"):
                continue
            if "<system-reminder>" in text:
                continue
            entry = "**%s**: %s\n" % (rec["type"], text[:MAX_MSG])
            total += len(entry)
            if total > MAX_TOTAL:
                break
            out.append(entry)

    # Require some real back-and-forth before spending tokens on extraction.
    if sum(1 for e in out if e.startswith("**user**")) < 2:
        return
    print("\n".join(out))


if __name__ == "__main__":
    main(sys.argv[1])
