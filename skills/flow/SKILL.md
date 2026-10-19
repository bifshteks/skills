---
name: flow
description: Shared contract the /pivo:shape, /pivo:grill, /pivo:spec, /pivo:tickets and /pivo:implement phases load first
user-invocable: false
---

# Workspace

## Prerequisites

Setup is lazy: fix a prerequisite the moment its symptom shows, then resume the
phase.

| Symptom | Fix |
|---|---|
| A repo has no known path | § Resolving a repo |
| The forge CLI (`glab` for GitLab, `gh` for GitHub) reports not logged in, or `401` | The user runs `glab auth login --hostname <host>` / `gh auth login` — it needs a browser. Stop and wait. |
| The issue tracker's tools are absent from the session | Tell the user which MCP server or CLI is missing; carry on without the ticket if they say so. |


## Approval gate

How a phase asks the user to approve a file it wrote:

1. Print the file in full as text in your message.
2. One `AskUserQuestion` with the phase's options, the file's content in the
   `preview` of every option, and no option labelled `(Recommended)`.
3. Anything but "Yes" reopens that part. Rewrite the file and run the gate again.

## Tickets in the tracker

Read the ticket through whatever the session has for the project's tracker —
an MCP server or a CLI for Jira, GitHub or GitLab issues, Linear.

A ticket is optional. "No ticket" is a legitimate answer. When there
is one, its key is the only thread between the ticket and the merge requests, so it
carries all three names:

| | With a ticket | Without |
|---|---|---|
| `<slug>` | `<TICKET-KEY>` | short kebab-case name for the change |
| branch | `<TICKET-KEY>-<ticket-slug>` | `<slug>-<ticket-slug>` |
| MR title | `<TICKET-KEY>: <ticket title>` | `<ticket title>` |

## Inputs

A phase reads the best input the effort has, in this order, and goes no lower
than it needs:

1. `issues/NN-*.md`
2. `spec.md`
3. `understanding.md`
4. `intent.md`
5. the user's prompt

Work with what is there. If an earlier phase would have helped, suggest it in the
Next block.

**No effort yet.** Started from a bare prompt: one `AskUserQuestion` — a ticket
key, an existing effort under `work/`, or none. Agree the `<slug>` per the naming
table and create `work/<slug>/`.

**No grill behind it.** Starting below `understanding.md` means nobody has
settled the design. Ask only the **blockers** — decisions with no safe default:
a contract or schema, a change spanning several repos, anything irreversible —
one `AskUserQuestion` each, recommended option first. Decide everything else
yourself and write it down as *assumed*, where the phase records decisions. A
wrong assumption in writing gets caught at a gate or in review; a silent one does
not.

## Next — your call

The user picks the path. Every phase ends by suggesting what could come next, then
stops. Print the suggestion as text after the phase's last output — a button click
cannot start a slash command:

```
Next — your call:
- /pivo:<phase> — <why, from this effort: repos touched, contracts,
  deploy ordering, open questions, size>
- /pivo:<phase> — <the alternative, and when it is the better choice>
```

One or two lines, the more likely first. The reason is about this effort, not
the phase in general — "one repo, no contract change", not "for small tasks".
Each phase says which options it weighs.
