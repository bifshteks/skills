---
name: review
description: Review a branch, diff or merge request from every role it touches. Use before pushing or on a merge request, in a project without its own review skill.
---

# Review

You orchestrate; `pivo:reviewer` agents grade, one role each.

## Scope

The **range** is `origin/HEAD...HEAD`, or starts at the commit, branch or tag
the user named; with uncommitted changes, it is `git diff <merge-base>`. A merge
request is `<target>...<head>`, reviewed from a throwaway worktree at its head so
reviewers read the code the diff produces.

The **goal** is the issue file when `/pivo:implement` called you, else the ticket
or MR description, else the user's sentence, else inferred from the commit
messages, and the report says so.

## Roles

| Role | Runs when the diff |
|---|---|
| product-owner | always |
| mr-reviewer | always |
| security | always |
| maintainer | changes code |
| architect | changes code |
| on-duty | changes code that runs in production |
| integrator | changes what someone else reads: an API, a schema, stored data, config, a message format, metric or log names |

Each role's text is `roles/<role>.md`.

## Dispatch

One `pivo:reviewer` per role, all in one message, in the foreground
(`run_in_background: false`): the filter needs every report, and a background
reviewer can outlive a review that runs as a subagent. Each prompt carries:

- the repository path and the exact range
- the absolute path of `roles/<role>.md` under this skill's base directory
- the goal: the issue file's path, or the text
- the other roles in this round
- from round two: that role's Blocks from the last round, and the commit that
  round reviewed

A reviewer that fails, or whose Covered skips what its role's Done names, is
dispatched once more; failing again, you grade that role yourself and say so in
the report.

Without the Agent tool — at the subagent depth limit — grade each role yourself,
one at a time, reading its role file fresh before each.

## Filter

Start once every reviewer has reported. Recall is theirs; precision is yours.

1. **What breaks.** Each concern gets one phrase: what specifically breaks, or
   who suffers, if it ships unfixed? It is a **Block** only with a concrete
   answer you confirmed in the code yourself:
   - a requirement of the goal is missing, partial, or built on the wrong reading
   - CI or production falls over
   - a vulnerability, or one tenant's data reachable by another
   - data lost, duplicated or corrupted
   - a reader of existing data, a deployed consumer or an API client breaks
   - on-call cannot tell from telemetry that it broke, where, or why
   - the logic is wrong for some input
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
2. After a fix, re-run the roles that raised Blocks, `product-owner`, and any
   role the fix newly touches.
3. After a rebase, re-run `integrator`, `security` and `product-owner`.
4. Three rounds at most. Blocks still standing at round three mean the goal is
   wrong, not the code: stop, report what is outstanding, and leave the decision
   to the user.

## Report

The range and the goal first. Then Blocks, highest severity first, each as
`file:line — what breaks — what to do — roles`, and one line naming the roles
with nothing to block. Then what no reviewer could reach and what it leaves
unverified, and the Ideas, one line each with why they matter. Close with the
single most important fix, or state plainly that the diff is clean.
