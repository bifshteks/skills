---
name: stateful-harness
description: Use before saving anything that must outlive this session or be read by another session or subagent, when resuming a ticket or task worked on before, and before parallel agents edit shared files.
user-invocable: false
---

Durable state lives under `~/.pivo`, outside every repo. Every operation goes through
`${CLAUDE_SKILL_DIR}/scripts/store.sh`; run it bare for usage. It only reports,
through stdout and exit code: acting on a result is the caller's rule.

## Pick the directory

State belongs to a **unit of work**: one piece of work the user does, usually a
ticket, often split across many sessions and subagents. Each gets its own directory
in `~/.pivo/work/`.

1. Name it `<TICKET>-<slug>` when there is a ticket, `<slug>` otherwise. The slug is
   a short kebab-case name for the angle of work, so one ticket can own several
   directories: `QWE-123-api-spike`, `QWE-123-migration-plan`.
2. `${CLAUDE_SKILL_DIR}/scripts/store.sh find <TICKET|slug>` — resume a listed
   directory when it is this work.
3. Otherwise `${CLAUDE_SKILL_DIR}/scripts/store.sh dir <name>`, which creates it and
   prints the path.

A file directly in `~/.pivo` (`${CLAUDE_SKILL_DIR}/scripts/store.sh root`) is for
state that belongs to no unit of work. That is rare: default to a directory.

## One writer per file

Many agents can share a directory; each file has one writer at a time.

- Dispatching agents: give each its own file. Nothing to lock.
- A file several agents must write: hold its lock for the edit.

```bash
${CLAUDE_SKILL_DIR}/scripts/store.sh lock <file> <owner>   # exit 1: held by someone else; stdout names them
# edit <file>
${CLAUDE_SKILL_DIR}/scripts/store.sh unlock <file> <owner>
```

`<owner>` names you to the others (the subagent's task, or the session) and is the
same string on `lock` and `unlock`, which checks it. The lock is a sibling
`<file>.lock`, so the file's content stays free for whatever status scheme the caller
uses.
