---
name: stateful-harness
description: Use before saving anything that must outlive this session or be read by another session or subagent, when looking up state saved before, and before parallel agents edit shared files.
user-invocable: false
---

Durable state lives under `~/.pivo`, outside every repo. Every operation goes through
`${CLAUDE_SKILL_DIR}/scripts/store.sh`; run it bare for usage.

It is a dumb store: directories, name lookups and file locks. It does not know what a
directory is for, how it is named, or which one to resume. The caller decides the
layout and the names, and acts on what `store.sh` reports through stdout and exit
code.

## Directories

Paths are relative to `~/.pivo` and cannot leave it.

```bash
${CLAUDE_SKILL_DIR}/scripts/store.sh root              # create ~/.pivo; print it
${CLAUDE_SKILL_DIR}/scripts/store.sh mkdir <path>      # create ~/.pivo/<path> (parents too); print it
```

## Find

```bash
${CLAUDE_SKILL_DIR}/scripts/store.sh find <mode> <parent> <query>
```

Prints every directory directly inside `~/.pivo/<parent>` (`.` for `~/.pivo` itself)
whose name matches, one absolute path per line; exit 1 when none does.

| mode | matches when the name |
|---|---|
| `exact` | equals `<query>` |
| `prefix` | starts with `<query>` |
| `suffix` | ends with `<query>` |
| `approx` | contains every word of `<query>`, ignoring case, order and `-` `_` `.` space |

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
same string on `lock` and `unlock`, which checks it. `unlock --force` frees a lock
whose holder is gone. The lock is a sibling `<file>.lock`, so the file's content
stays free for whatever status scheme the caller uses.
