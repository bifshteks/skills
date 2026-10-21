---
name: repofind
description: Find a repo's path on this machine and what it is for. Use whenever a task names a repo or service you have no path for — even just one, even by short name ("in logrotate", "the exporter") — spans several repos, or refers to a workspace. Most repos have several clones and worktrees here; resolve first, before find or a guessed path.
---

# repofind

`mur` cli is the authority on which repos a workspace holds, what each is for, and
where each is cloned on this machine. Ask it; don't guess.

1. Once per session, before any other mur call, run `mur agent-guide` and follow
   it. It is the only manual for mur, and this skill does not repeat it.
2. Before working across a workspace, run `mur workspace show`, naming the
   workspace if the task does.
3. For each repo you touch, run `mur resolve` and work in the path it returns.

When mur cannot answer, do what `mur agent-guide` says for that case.
