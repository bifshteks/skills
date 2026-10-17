#!/usr/bin/env bash
# Scaffold a new skill: scripts/new-skill.sh <name> ["what it does and when to use it"]
# The skill becomes available as /pivo:<name> once pushed.
set -euo pipefail

name="${1:-}"
description="${2:-TODO: what this skill does, and when Claude should use it.}"

if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || (( ${#name} > 64 )); then
  echo "usage: $0 <name> [description]" >&2
  echo "name: lowercase letters, digits and hyphens, at most 64 characters (e.g. code-review)" >&2
  exit 1
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$root/skills/$name"

if [[ -e "$dir" ]]; then
  echo "skills/$name already exists" >&2
  exit 1
fi

mkdir -p "$dir"
cat > "$dir/SKILL.md" <<SKILL
---
name: $name
description: $description
---

# $name

TODO: instructions Claude follows when this skill is used.
SKILL

echo "created skills/$name/SKILL.md — available as /pivo:$name after you push"
