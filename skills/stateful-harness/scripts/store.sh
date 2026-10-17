#!/usr/bin/env bash
# Persistent storage for agents under ~/.pivo. See ../SKILL.md.
set -euo pipefail

usage='usage:
  store.sh root                              create ~/.pivo if missing; print it
  store.sh find <TICKET|slug>                print matching unit-of-work dirs; exit 1 if none
  store.sh dir <name>                        create ~/.pivo/<name> if missing; print it
                                             name: <slug> or <TICKET>-<slug>
  store.sh lock <file> <owner>               exit 0: acquired; exit 1: held, prints "<owner> <time>"
  store.sh unlock <file> <owner> [--force]   exit 0: released; exit 1: not yours, prints holder
exit 2: bad usage or invalid name'

root="$HOME/.pivo"
slug='[a-z0-9]+(-[a-z0-9]+)*'
ticket='[A-Z][A-Z0-9]*-[0-9]+'

die() { echo "store.sh: $2" >&2; exit "$1"; }

# A unit-of-work directory is <slug> or <TICKET>-<slug>.
valid_name() { [[ "$1" =~ ^($ticket-)?$slug$ ]]; }

case "${1:-}" in
  root)
    mkdir -p "$root"
    echo "$root"
    ;;
  find)
    q="${2:-}"
    if [[ "$q" =~ ^$ticket$ ]]; then match="^$q-$slug$"
    elif [[ "$q" =~ ^$slug$ ]]; then match="^($ticket-)?$q$"
    else die 2 "invalid query '$q': want a ticket key (QWE-123) or a slug (fix-login)"
    fi
    found=1
    for d in "$root"/*/; do
      [[ -d "$d" ]] || continue
      d="${d%/}"
      [[ "${d##*/}" =~ $match ]] || continue
      echo "$d"
      found=0
    done
    exit "$found"
    ;;
  dir)
    valid_name "${2:-}" || die 2 "invalid name '${2:-}': want <slug> or <TICKET>-<slug>, e.g. QWE-123-fix-login"
    mkdir -p "$root/$2"
    echo "$root/$2"
    ;;
  lock)
    [[ -n "${2:-}" && -n "${3:-}" ]] || die 2 "usage: store.sh lock <file> <owner>"
    lock="$2.lock"
    # set -C makes > fail if the file exists (O_EXCL): exactly one creator wins.
    if ( set -C; printf '%s %s\n' "$3" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$lock" ) 2>/dev/null; then
      exit 0
    fi
    [[ -e "$lock" ]] || die 2 "cannot create $lock"
    cat "$lock"
    exit 1
    ;;
  unlock)
    [[ -n "${2:-}" && -n "${3:-}" ]] || die 2 "usage: store.sh unlock <file> <owner> [--force]"
    lock="$2.lock"
    if [[ "${4:-}" == --force ]]; then
      rm -f "$lock"
      exit 0
    fi
    [[ -e "$lock" ]] || exit 1
    held="$(cat "$lock")"
    if [[ "${held% *}" != "$3" ]]; then
      echo "$held"
      exit 1
    fi
    rm "$lock"
    ;;
  *)
    die 2 "$usage"
    ;;
esac
