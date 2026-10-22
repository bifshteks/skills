---
name: review
description: Review a branch or diff from the roles it touches. Use before pushing, on a merge request, or from /pivo:implement.
---

# Review

Usable on its own: a branch you wrote by hand, a teammate's MR, anything. You
orchestrate; `pivo:reviewer` agents grade, one role each.

## Scope

Default to `<base>...HEAD`, where `<base>` is `origin/HEAD`. Otherwise review
since whatever fixed point the user named — commit, branch, tag — or the diff of
the MR they pointed at.

## Roles

| Role | Runs when the diff | Role text |
|---|---|---|
| product-owner | always | [`roles/product-owner.md`](roles/product-owner.md) |
| mr-reviewer | always | [`roles/mr-reviewer.md`](roles/mr-reviewer.md) |
| maintainer | changes code | [`roles/maintainer.md`](roles/maintainer.md) |
| on-duty | changes code that runs in production | [`roles/on-duty.md`](roles/on-duty.md) |
| backcompat | changes what someone else reads — an API, a schema, stored data, config, a message format | Who reads this today — old data, deployed consumers mid-rollout, API clients — and what breaks for them? |
| security | always | [`roles/security.md`](roles/security.md) |

## Dispatch

One `pivo:reviewer` per role the diff touches, all in the same message and in
the foreground (`run_in_background: false`): the filter needs every report, and
a background reviewer can outlive a review that runs as a subagent. Each prompt
carries:

- the repository path and the exact range
- the role: the absolute path of its file (relative to this skill's base
  directory), or its line from the table
- the goal: the issue file's path, or the text
- the other roles in this round

The filter starts once every reviewer has reported. A reviewer that fails is
dispatched once more; failing again, you grade its role yourself and say so in
the report.

Without the Agent tool — at the subagent depth limit — grade each role yourself,
one at a time, reading its role text fresh before each.

## Filter

Reviewers report every concern; you run the one filter pass.

1. **What breaks.** Each concern gets one phrase: what specifically breaks, or
   who suffers, if it is not fixed? It is a **Block** only with a concrete
   answer:
   - a requirement of the goal is missing, partial, or built on the wrong reading
   - CI or production falls over
   - a vulnerability, or one tenant's data reachable by another
   - data lost, duplicated or corrupted
   - a reader of existing data, a deployed consumer or an API client breaks
   - on-call cannot tell from telemetry that it broke, where, or why
   - the logic is wrong
   - a reviewer cannot verify it from the diff: logic buried in a refactor or a
     move, or more than one sitting can hold
   - the next change costs materially more
   Anything else is an Idea or is dropped.
2. **Duplicates.** One concern raised by several roles becomes one Block naming
   every role.
3. **Conflicts.** Two Blocks asking opposite things — more telemetry here, less
   noise in the logic — become one Block with the fix that satisfies both, or go
   to the user when none does.
4. **Ideas.** Keep the three strongest across all roles, round one only.

## Rounds

1. Round one runs every role the diff touches.
2. After a fix, re-run the roles that raised Blocks, plus `product-owner`.
3. After a rebase, re-run `backcompat`, `security` and `product-owner`.
4. Three rounds at most. Blocks still standing at round three mean the goal is
   wrong, not the code: stop, report what is outstanding, and leave the decision
   to the user.

## Report

The range first. Then Blocks grouped by role, each as `file:line — what breaks —
what to do`; a role with nothing to block gets one line saying so. Then the
Ideas, one line each with why they matter. Close with the single most important
fix, or state plainly that the diff is clean.
