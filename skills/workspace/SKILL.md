---
name: workspace
description: Shared contract the /pivo:shape, /pivo:grill, /pivo:spec, /pivo:tickets and /pivo:implement phases load first — the ~/.pivo layout, repo resolution, project context, approval gate, naming, inputs and the Next block.
---

# Workspace

## Prerequisites

Setup is lazy: fix a prerequisite the moment its symptom shows, then resume the
phase.

| Symptom | Fix |
|---|---|
| A repo has no known path | § Resolving a repo |
| The forge CLI (`glab` for GitLab, `gh` for GitHub) reports not logged in, or `401` | The user runs `glab auth login --hostname <host>` / `gh auth login` — it needs a browser. Stop and wait. |
| `.scratch` listed as untracked in `git status` | Append `.scratch` — **no trailing slash**, git treats a symlink as a file — to the file `git config --global core.excludesfile` names; if unset, use `~/.config/git/ignore` and set it. Done when `git check-ignore -v .scratch` matches in a worktree. |
| The issue tracker's tools are absent from the session | Tell the user which MCP server or CLI is missing; carry on without the ticket if they say so. |

## Project context

Before forming any opinion about a change, read what the project says about
itself, in this order, and proceed silently past whatever is absent:

1. The repo's `CLAUDE.md` / `AGENTS.md`, and `docs/adr/` if present.
2. When the change belongs to a workspace (`mur workspace show <name>`, see
   `pivo:multirepo`): which repo does what.
3. Any skill in this session that describes the project — its domain glossary
   (a `<team>-context`-style skill), its code style, its review, its MR
   description format, its watching of open merge requests. Its name usually
   carries the team or project name.

A project skill beats the generic default every phase falls back on. Name the ones
you found when you first use them.

## Where things live

```
~/.pivo/
  work/<slug>/            one effort: intent.md, understanding.md, spec.md, issues/NN-<slug>.md
  wt/<repo>/<ticket>/     one git worktree per ticket, .scratch -> work/<slug>/
```

Artifacts live only under `work/<slug>/`, outside every repo's history. Each
worktree reads them through its `.scratch` symlink.

## Resolving a repo

Every repo path comes from a resolver; the working directory is at most a hint
about scope.

- The repo is in a mur workspace: `pivo:multirepo` — `mur resolve` and its
  agent guide decide the path and what to do when it cannot.
- The working directory is that repo: use it.
- Otherwise ask the user — one question, two options: give the path, or clone it
  (then ask where, and `git clone` the canonical URL). Note the path in the issue
  file's `## Comments` for the next session.

Stop at a non-zero exit rather than run `git -C ""` in whatever repo you happen
to be in.

## Approval gate

How a phase asks the user to approve a file it wrote:

1. Print the file in full as text in your message.
2. One `AskUserQuestion` with the phase's options, the file's content in the
   `preview` of every option, and no option labelled `(Recommended)`.
3. Anything but "Yes" reopens that part. Rewrite the file and run the gate again.

## Tickets in the tracker

Read the ticket through whatever the session has for the project's tracker —
an MCP server or a CLI for Jira, GitHub or GitLab issues, Linear.

A ticket is optional. "No ticket" is a legitimate answer — plenty of changes start
as "I want to change X" — and every phase runs identically without one. When there
is one, its key is the only thread between the ticket and the merge requests, so it
carries all three names:

| | With a ticket | Without |
|---|---|---|
| `<slug>` | `<TICKET-KEY>` | short kebab-case name for the change |
| branch | `<TICKET-KEY>-<ticket-slug>` | `<slug>-<ticket-slug>` |
| MR title | `<TICKET-KEY>: <ticket title>` | `<ticket title>` |

A project's own convention for branch or MR names, from § Project context, wins.

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
