# pivo skills

A Claude Code plugin with shared skills. Each skill in `skills/` is available as `/pivo:<skill-name>`.
For example, `skills/qwe/SKILL.md` becomes `/pivo:qwe`.

## Install

You need read access to this repo. Claude Code clones it over SSH (`git@github.com:bifshteks/skills.git`) with your existing git credentials.
Check access with `git ls-remote git@github.com:bifshteks/skills.git`.
The repo is private, so github.com and raw links return 404 to anyone without access.

In an interactive `claude` terminal:

```
/plugin marketplace add bifshteks/skills
/plugin install pivo@pivo
```

Then run `/reload-plugins` or restart Claude Code.

`/plugin` opens an interactive menu, so it does not work in the Claude desktop app's Code tab. There, or from any shell, use the CLI:

```bash
claude plugin marketplace add bifshteks/skills
claude plugin install pivo@pivo
claude plugin list   # pivo@pivo should show Status: enabled
```

The plugin is picked up by sessions started after the install.

`pivo@pivo` is `<plugin>@<marketplace>`: the marketplace in `marketplace.json` and its only plugin are both named `pivo`.

### Updates

Every push to `master` is a new version. To pull it:

```
/plugin marketplace update pivo
```

or `claude plugin marketplace update pivo` from a shell.

To update automatically at startup, turn on auto-update for the `pivo` marketplace in `/plugin` → **Marketplaces**.
Because the repo is private, background updates also need `GITHUB_TOKEN` set in your environment.
If plain `git` over HTTPS asks for a username, run `gh auth setup-git`.

### Enable for a whole project

Add this to a project's `.claude/settings.json` so everyone who trusts the project is prompted to install the plugin:

```json
{
  "extraKnownMarketplaces": {
    "pivo": { "source": { "source": "github", "repo": "bifshteks/skills" } }
  },
  "enabledPlugins": { "pivo@pivo": true }
}
```

## Change workflow

An opinionated path from a fuzzy want to open merge requests. Each phase is invoked by you, runs alone, and ends by suggesting the next one with a reason. You pick the path:

- `/pivo:grill` → `/pivo:spec` → `/pivo:tickets` → `/pivo:implement`: several repos, contracts, deploy ordering
- `/pivo:grill` → `/pivo:spec` → `/pivo:implement`: one repo, but you want to read the spec before code
- `/pivo:grill` → `/pivo:implement`: the decisions fit in `understanding.md`
- `/pivo:implement` alone: it all fits in one prompt

`/pivo:shape` is optional before any of them, for when the problem is not clear yet.

Artifacts (`intent.md`, `understanding.md`, `spec.md`, `issues/`) live in `~/.pivo/work/<slug>/`, and worktrees live in `~/.pivo/wt/`. Both are described in `pivo:workspace`, the contract every phase loads first.
The phases know nothing about any particular project. They read the repo's `CLAUDE.md` / `AGENTS.md`, and they prefer any project skill in the session for the glossary, style, review, MR description or watching MRs. Without one, they fall back to their own defaults, such as `pivo:mr-description`.

## Add a skill

```bash
scripts/new-skill.sh qwe "What qwe does, and when Claude should use it."
```

This creates `skills/qwe/SKILL.md`. Write the instructions, then commit and push. Users get `/pivo:qwe` on their next update.

Skill layout:

```
skills/qwe/
├── SKILL.md        # required: frontmatter (name, description) + instructions
├── reference.md    # optional: extra docs that SKILL.md links to
└── scripts/        # optional: helpers the skill runs
```

- The directory name is the skill name: lowercase letters, digits and hyphens.
- Claude uses `description` to decide when to load the skill on its own, so say what the skill does *and* when to use it.

To test locally before pushing:

```bash
claude --plugin-dir .
```

## Layout

```
.claude-plugin/
├── plugin.json        # plugin manifest; "name": "pivo" sets the /pivo: prefix
└── marketplace.json   # makes this repo installable with /plugin marketplace add
skills/                # one directory per skill
scripts/new-skill.sh   # skill scaffold
```

`plugin.json` has no `version` on purpose: Claude Code then uses the git commit as the version, so every push is an update.
If you add a `version`, you must bump it on each release or users will not get the change.
