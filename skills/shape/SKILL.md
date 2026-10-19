---
name: shape
description: "Shape a change the user cannot state yet: find the problem behind a hunch, ticket or ready-made solution, compare framings, write intent.md. Optional, before /pivo:grill or /pivo:implement, when the want is fuzzy."
disable-model-invocation: true
---

# Shape

Call the Skill tool for `pivo:flow` before anything else: the effort, the
naming and the project context live there.

Grilling settles **how**. This settles **what for**.

## How to talk

**Ask in prose, at most two open questions per turn; save `AskUserQuestion` for
the approval gate.** Options drafted before the problem is known are your
framing. **Draw the goal out of the user in their own words.**

Do the legwork between turns — tickets, code, earlier efforts — so each question
you ask is one only the user can answer.

## Find what is behind the ask

**Parent ticket.** A parent ticket often states the goal the ask leaves out. With
a key, read it from the tracker. Without one, search the tracker for the area and
ask whether this serves a ticket, epic or incident that is not its own. Read it
before forming any view of the change.

**Earlier work.** List earlier efforts per `pivo:flow` § The effort and read any
one touching the same area. Ask whether this continues, replaces or reverts it —
and if replaces, what was wrong with it.

**Mechanism-shaped asks.** When the ask names a mechanism ("add a retry", "add a
metric"), ask what it is meant to achieve, then whether the mechanism is the only
way there. Mechanism words collide like glossary words; say which reading you
took.

Questions that tend to work:

- What prompted this now — an incident, a complaint, a review, an itch?
- After this ships, what will you or someone else see, do, or stop doing?
- Who notices if it is never done?
- Imagine it is merged and you are disappointed. Why?

## Show framings

Once the problem is on the table, offer two or three framings that differ in what
they would build — not three variants of one design. Include the smallest version
that tests the idea, and "not now" when that is honest. For each: what it gets,
what it costs, what it leaves out.

Where the user will judge the result by looking at it — a dashboard, metric names
and labels, an alert, an MR description, an API payload, a CLI's output — sketch
what they would see. Wants a user cannot name surface the moment they see
something concrete.

The user picks, mixes or rejects them in their own words.

## Intent

Find or create the effort per `pivo:flow` § The effort, named after the ticket
this serves if you found one. Write `<effort>/intent.md`:

```markdown
# <name> — intent

## Problem
What is wrong or missing today, for whom. Who asked; the ticket, if any.

## Outcome
What is different once this ships, in the user's words.

## How we will know
What someone observes that shows it worked: an alert that fires, a panel that
answers a question, a behaviour. Concrete enough to check after merge.

## Not doing
Framings considered and set aside, each with its reason.

## Open
What is still unknown, and who would know.
```

Run the approval gate from `pivo:flow`: "Does this say what you want?" —
"Yes", "The problem is wrong", "The outcome is wrong", "Something is missing".

Done when the user says yes. If **Outcome** or **How we will know** cannot be
filled, the change is not ready to grill — say so and stop.

Then stop, and end with the Next block from `pivo:flow`. Weigh:

- `/pivo:grill` — design decisions are still open: **Open** is not empty, more
  than one repo, a contract, something irreversible.
- `/pivo:implement` — very easy: one repo, no contract, and the intent already
  says what to build.
