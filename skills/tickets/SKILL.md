---
name: tickets
description: "Break a spec into tickets, one file per ticket under the effort's issues/ — one ticket, one repo, one merge request, with explicit blocking edges. Stops at a gate for your approval of the breakdown."
disable-model-invocation: true
---

# Tickets

Call the Skill tool for `pivo:flow` before anything else: the effort, the
naming and the project context live there.

This is the one phase that needs its input: `<effort>/spec.md`, with the effort
found per `pivo:flow` § The effort. Without it, stop and end with the Next block from `pivo:flow` offering
`/pivo:spec` — and `/pivo:implement`, which cuts its own tickets when the change
is small enough to skip both.

Break the spec into tickets. One per file, numbered from `01`:

```
<effort>/issues/01-<ticket-slug>.md
```

Never a single combined tickets file.

## One ticket, one merge request

A ticket is the unit of a worktree, a branch and an MR. So a ticket targets
**exactly one repo**. A change spanning three repos is at least three tickets.

## Issue file

```markdown
# <title>

Repo: <host>/<group>/<repo>
Status: open
Blocked by: 02        # omit when nothing blocks it

## Goal

What this ticket achieves, and the slice of the spec it covers.

## Context

What an implementing session needs that is not in the diff: the decisions from the
spec that apply here, the glossary readings, the contract constraints.

## Done when

Checkable conditions. Not "implement X" but what is true once X is implemented.

## Comments

<!-- sessions append progress and decisions below -->
```

The `Repo:` line is load-bearing: it is how `/pivo:implement` finds the repo on a
laptop whose layout it does not know. Always the canonical URL, never a local
path.

Triage strings, if used: `needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, `wontfix`.

## Sizing and ordering

- A ticket an implementing session can finish and get reviewed in one sitting.
- Say so when two tickets touch the same files in the same repo. They will need
  stacking or sequencing, and that is the user's call at this gate, not a surprise
  during implementation.
- `Blocked by` only for real dependencies — a contract that must exist before a
  consumer can use it, a schema before a producer writes it. Deploy ordering from
  the spec usually implies some of these.
- A change to a contract shared across repos is almost always its own ticket,
  landing first.

## Gate 2

Done when every ticket file has a `Repo:` line, a `Goal`, a `Done when` section,
and either a `Blocked by` line or a deliberate absence.

Show the user the breakdown: each ticket, its repo, its dependencies, and which
can run in parallel. Call out overlaps and the implied ordering.

Wait for approval. A bad decomposition becomes several worktrees of wasted work,
which is exactly what this gate exists to prevent.

Then stop, and end with the Next block from `pivo:flow`: `/pivo:implement`,
naming which tickets are unblocked and can go out first.
