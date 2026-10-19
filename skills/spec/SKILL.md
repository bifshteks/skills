---
name: spec
description: "Write the spec for a change to ~/.pivo/work/<slug>/spec.md: what and why, repos affected, decisions settled, contracts touched, deploy ordering, out of scope. Stops at a gate for your approval."
disable-model-invocation: true
---

# Spec

Call the Skill tool for `pivo:workspace` before anything else: the paths, the
resolver and the project context live there.

Read the effort's input per **Inputs** in `pivo:workspace`: `understanding.md`
from `~/.pivo/work/<slug>/`, and `intent.md` if it exists. The spec
elaborates `understanding.md` and never contradicts it. Without one, work from
`intent.md` or the prompt; its *assumed* decisions go in the spec's Decisions,
where Gate 1 catches them.

Write `~/.pivo/work/<slug>/spec.md`. Create the directory if needed.

The spec is for the implementing sessions, which start cold and will not have the
grilling conversation. Everything they need to not re-litigate settled questions
goes in here.

## Contents

- **What and why.** The change, and the problem it solves. One short section.
- **Outcome and how we will know**, from `understanding.md`, in the user's words.
- **Ticket key**, if there is one.
- **Repos affected**, by canonical URL, with what changes in each.
- **Decisions settled during grilling**, each with its reasoning. This is the part
  that stops an implementing session from re-opening a closed question.
- **Domain terms** as resolved against the project's glossary — especially any
  word that was ambiguous. Name the reading taken.
- **Contracts touched**: shared schemas and events, storage layout, queues and
  topics, APIs, config keys. For each, how compatibility is preserved.
- **Deploy ordering**, if more than one component changes.
- **Out of scope.** Explicit. Review grades scope creep against this, so an empty
  section costs you later.
- **Open questions**, if any survived grilling. If one blocks implementation, say
  so — it means grilling was not finished.

Done when every section above is present, or explicitly marked none.

Use the glossary's vocabulary throughout. Do not drift to synonyms it avoids.

## Gate 1

Show the user the spec. Wait for approval. Edits are expected — this is the
cheapest point in the whole effort to change direction.

Then stop, and end with the Next block from `pivo:workspace`. Weigh:

- `/pivo:tickets` — several repos, a contract that must land first, deploy
  ordering, or two changes in one repo that need sequencing.
- `/pivo:implement` — one repo, one MR; implement cuts the single ticket itself.
