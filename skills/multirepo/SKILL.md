---
name: multirepo
description: Locate and work across several git repositories with mur. Use when a task touches more than one repo, names a repo you have no path for, or refers to a workspace such as auditlogs or modelhub, before guessing a path or searching the disk.
---

# multirepo

`mur` is the authority on which repos a workspace holds, what each is for, and
where each is cloned on this machine. Ask it; don't guess.

1. Once per session, before any other mur call, run `mur agent-guide` and follow
   it. It is the only manual for mur, and this skill does not repeat it.
2. Before working across a workspace, run `mur workspace show`, naming the
   workspace if the task does.
3. For each repo you touch, run `mur resolve` and work in the path it returns.

When mur cannot answer, do what `mur agent-guide` says for that case.
