---
name: grill
description: "Intake and grill a change: read the ticket or the described change, settle the outcome it serves, resolve its words against the project's glossary, then interview the user one question at a time until the design tree is settled. Writes the effort's understanding.md for the user to approve."
disable-model-invocation: true
---

# Grill

Call the Skill tool for `pivo:flow` before anything else: the effort, the
naming and the project context live there.

## Intake

Ask whether there is a ticket, through `AskUserQuestion`. An earlier effort with
`intent.md` and no `understanding.md` means `/pivo:shape` ran for it: offer it as
an option too, and that is the effort.

With a ticket, read it from the tracker; without one, the user describes the
change. Find or create the effort per `pivo:flow` § The effort.

### Outcome first

If `<effort>/intent.md` exists, read it: its **Problem**, **Outcome** and **How
we will know** are settled. Skip to Words.

Otherwise search the tracker for a parent ticket that states the goal, and list
earlier efforts in the same area. Then ask the user, in
prose and before any design question: **what should be different once this
ships, and how will you notice?**

- An answer naming a mechanism without a problem — ask what the mechanism is for.
- "Not sure", or nothing concrete — stop, and end with the Next block from
  `pivo:flow` offering `/pivo:shape`.

### Words

Then read the project context per `pivo:flow`. Resolve every domain word in
the ask against the project's glossary, where it has one, **before** forming any
opinion about the change. Domain words collide with internal component names —
one word for a user-facing resource and a background process, "queue" meaning
three different things — and a whole effort built on the wrong reading is the most
expensive mistake available at this stage. Mechanism words collide the same way.

Say which reading you took when the word was ambiguous.

## Grill

Interview the user until you reach a shared understanding. Map it as a design
tree: each decision branches into the decisions hanging off it. **The root is the
outcome.** A decision that serves no part of it is scope creep or a missing goal —
ask which.

**Every design question goes through `AskUserQuestion`, one at a time.** Never
a numbered list, never two questions in one turn. The user answers by clicking,
so the whole grill costs them clicks instead of typing.

Each call:

- exactly one question in the `questions` array
- 2–4 options, **your recommended one first, labelled `(Recommended)`**
- a `description` per option saying what it means and what it costs
- a `header` of at most 12 characters

Having no recommendation is itself an answer: look the fact up before asking.

A free-text answer means your options missed something. When it reopens an
earlier answer or questions the outcome, go back to that node and recompute the
frontier — do not carry on down a branch the user just cut.

The **frontier** is every decision whose prerequisites are settled. Ask the one
on the frontier that constrains the most downstream decisions — the answer that
collapses the most of the tree. Each answer pushes the frontier outward;
recompute and ask the next single question. A decision depending on one still
open is not on the frontier; it waits.

Finding **facts** is your job, never the user's. A frontier question needing a
fact from the environment — what a repo actually does, what a schema contains,
whether a field is already optional — gets looked up first, with the resolver for
paths. Only the **decisions** are the user's.

Make sure the tree reaches:

- which repos are affected — when the project is a workspace of several, check
  every repo in it, not just the obvious one
- whether any **contract shared with other teams or services** changes — an
  event or message schema, a public API, a library other repos import
- whether anything already written must stay readable (stored data and its
  layout, deployed consumers, existing API clients)
- what the deploy ordering is, if several components change
- whether this is reversible, and what config flag lets it be switched off in
  production without a deploy

## Sketch

When the user will judge the result by looking at it — a dashboard, metric names
and labels, an alert, an MR description, an API payload, a CLI's output — show
what they would see before confirming: the panel list, a sample series, a sample
payload. Wants a user cannot name surface the moment they see something concrete.

## Confirm

Done when the frontier is empty and every item above is settled. Write
`<effort>/understanding.md`:

```markdown
# <name> — understanding

## Outcome
## How we will know
## Decisions
One line each, with its reason.
## Not doing
## Sketch
Only if one was shown.
```

Run the approval gate from `pivo:flow`: "Does this match what you want?" —
"Yes", "The outcome is wrong", "The scope is wrong", "A decision is wrong".

## Decisions fall out of grilling

Grilling is where domain language gets settled and real decisions get made. When
that happens, record it where the project keeps such things — its glossary, an
ADR, `AGENTS.md` — per its own rules if it states them. Propose the place and
draft the text; the user approves. A decision that exists only in this transcript
is lost the moment the session ends.

Then stop, and end with the Next block from `pivo:flow`. Weigh:

- `/pivo:implement` — the decisions fit in `understanding.md`: one repo, no
  contract change, no deploy ordering.
- `/pivo:spec` — several repos, a shared contract, deploy ordering, or the user
  wants a written spec to review before code.
