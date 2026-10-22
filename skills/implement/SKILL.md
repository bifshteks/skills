---
name: implement
description: "Implement a change from whatever the effort has — tickets, spec, understanding, intent or a bare prompt — cutting its own tickets when there are none: a git worktree per ticket, test-first at agreed seams, review, then push and open the merge request. One ticket runs in this session; several fan out to background sub-agents or interactive sessions."
disable-model-invocation: true
---

# Implement, review, merge request

Call the Skill tool for `pivo:flow` before anything else: the effort, the
naming and the project context live there.

## Tickets

Find or create the effort per `pivo:flow` § The effort, then read its input per
**Inputs** there. Implement runs from any of them through to open MRs.

With `issues/`, those are the tickets. Without, cut them yourself from the best
input present — `spec.md`, `understanding.md`, `intent.md`, or the prompt:

- One ticket per repo the change touches, in the issue-file format from
  `/pivo:tickets`, numbered from `01`. One ticket, one repo, one MR still holds.
- `Blocked by` where one repo's change must land before another's — a contract
  before its consumer.
- Below `understanding.md`, *assumed* decisions go in the ticket's Context.
- No Gate 2: print the tickets and carry on.

## Fan out

One ticket runs in this session — no question.

Several: ask the user which mode, once per effort — the answer depends on the
tickets, so do not assume:

- **Background sub-agents** — tickets that are mechanical and unlikely to need a
  decision. No terminals to manage.
- **Separate interactive sessions** — tickets the user wants to drive. Print one
  ready-to-paste command per ticket: `cd` into its worktree, pointed at its issue
  file.

Either way, hand each ticket the absolute path of its issue file under
`<effort>/issues/`. That session is the only writer of that file.

Mixed is fine. Only unblocked tickets go out: a ticket with `Blocked by` waits
until every file it names is `Status: resolved`.

## Worktree per ticket

For each ticket, resolve its `Repo:` line to a local path per `pivo:repofind`,
then, with `store.sh` from `pivo:flow` § The effort:

```bash
REPO=<resolved path>
BASE=$(git -C "$REPO" symbolic-ref --short refs/remotes/origin/HEAD) || exit   # origin/main, origin/master, …
WT="$(store.sh root)/wt/<repo>/<ticket>"
git -C "$REPO" fetch origin
git -C "$REPO" worktree add -b <branch> "$WT" "$BASE"
```

`<branch>` and the MR title follow the naming table in `pivo:flow`.

The worktree holds only code. Every session reads the same spec and issue files
from `<effort>`, so a decision recorded in one is visible to the others.

The user's own clone is never touched beyond `fetch` and `worktree add` — no
branch switching, no stashing.

## Implementation session

A session handed no issue-file path finds the effort per `pivo:flow` § The
effort. Set `Status: claimed` in the issue file before any work.

Read, in order: the issue file, whichever of `spec.md`, `understanding.md` and
`intent.md` sit in `<effort>`, then the project context per `pivo:flow` — the
repo's `CLAUDE.md` / `AGENTS.md` and `docs/adr/`, the workspace's map of repos,
and the project's glossary and style skills. Proceed silently past what is absent.

Implement the ticket. Not the spec, not the adjacent thing you noticed — the
ticket. Review grades scope creep, and it is right to.

### Test-first. This one is not optional.

Every behaviour in this ticket is written as a failing test before the code that
makes it pass. Production code written ahead of a test that demanded it gets
deleted and redone.

**Agree the seams first.** A seam is the public boundary you observe behaviour
through — the project's acceptance or integration test entry point, an exported
function, a worker's unit of work. Before the first test, list the seams this
ticket is tested at and get the user to confirm them. No test is written at an
unconfirmed seam. You cannot test everything, and agreeing the seams up front is
how the effort lands on the critical path instead of on every edge case.

**Agree the failure points with them.** Alongside the seams, list every failure
point the ticket adds — each call that can fail or be slow, each path that leaves
a unit of work early — and the signal on-call would use to detect each one and
tell it from its neighbours. Walk them as the on-duty reviewer does, in
[`../review/roles/on-duty.md`](../review/roles/on-duty.md), starting from the
dashboards and alerts that already cover this unit of work. Each failure point is
a behaviour: its test injects the failure at the seam and asserts the telemetry
names it, through the project's in-memory span exporter, metric reader or log
capture. Telemetry is an output on-call reads, so asserting on it is not
implementation coupling.

**One slice at a time.** One seam, one failing test, the smallest code that
passes it, repeat. Never write the whole test suite first: bulk tests verify
behaviour you only imagined, they freeze a structure you do not understand yet,
and they go numb to the changes that matter. Each test is a tracer bullet —
write the next one knowing what the last one taught you.

**Red before green.** Run the test and watch it fail for the reason you expect
before writing any implementation. A test that has never been red proves
nothing. Then write only enough code to pass it — no speculative branches, no
anticipating the test after next.

The tests themselves follow the project's style where it states one. Prefer tests
against real dependencies at the outermost seam, fixtures over mocks, and each
reads as a story. Two things make a test worthless:

- **Implementation coupling** — asserting through a side channel (reading the DB
  instead of the interface), mocking internal collaborators, reaching at
  unexported state. The tell: a refactor that changes no behaviour breaks it.
- **Tautology** — the expected value computed the way the code computes it. It
  passes by construction and can never disagree with the implementation. Expected
  values come from somewhere independent: a literal from the spec, a worked
  example, a known-good payload.

Refactoring is not part of this loop. It happens after green, or in review.

Done when every behaviour the ticket's `Done when` section names has a test that
failed before its implementation existed.

Run the project's linter and its full test suite before review — the commands are
in `CLAUDE.md` / `AGENTS.md`, the `Makefile`, or the CI config. Review is not for
things the linter already catches.

Decisions made while implementing get recorded where the project keeps them, in
this MR where they are local to the repo.

## Review

If the session has a review skill for this project, invoke it on the branch, fix
what it finds, and loop under its rules. Otherwise call the Skill tool for
`pivo:review` on the branch, with the issue file as the goal, and fix its Blocks.

Either way, cap it at three rounds. Still finding real issues at round three means
the ticket is wrong, not the code: the branch stays unpushed until the user decides.

The review's Ideas go to the issue file's `## Comments` and the MR description,
where the user picks them up; the ticket ships without them.

## Push and open the MR

Push the branch and open the MR against the base branch with the forge's CLI —
`glab mr create` on GitLab, `gh pr create` on GitHub.

- Title: per the naming table in `pivo:flow`.
- Description: the project's own MR description format if it has one, otherwise
  call the Skill tool for `pivo:mr-description` and write it to that format.

If the CLI turns out not to be authenticated, stop and say so clearly, with the
branch pushed. Never leave finished work on an unpushed branch.

Before pushing a change to the CI config, lint it with whatever the forge offers
(`glab ci lint`, a CI-lint MCP tool) — cheaper than finding out from a red
pipeline.

Append to the issue file's `## Comments`: the MR URL and anything the next session
needs. Set `Status: resolved` once the MR is open.

## Then watch it

An open MR decays unwatched. If the session has a skill for keeping this project's
merge requests green, call it once the MRs are open. Otherwise list the MR URLs and
their pipeline status, and stop.
