# pivo skills

A Claude Code plugin with shared skills. Each skill in `skills/` is available as `/pivo:<skill-name>`.
For example, `skills/qwe/SKILL.md` becomes `/pivo:qwe`.

## Install

You need read access to this repo. Claude Code clones it with your existing git credentials (SSH key or `gh auth login`).

In Claude Code:

```
/plugin marketplace add bifshteks/skills
/plugin install pivo@pivo
```

Then run `/reload-plugins` or restart Claude Code.

### Updates

Every push to `master` is a new version. To pull it:

```
/plugin marketplace update pivo
```

To update automatically at startup, turn on auto-update for the `pivo` marketplace in `/plugin` → **Marketplaces**.
Because the repo is private, background updates also need `GITHUB_TOKEN` set in your environment.

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
