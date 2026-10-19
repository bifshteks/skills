#!/usr/bin/env bash
# Persistent storage for agents under ~/.pivo. See ../SKILL.md.
# Knows directories, names and locks; what a name means is the caller's business.
set -euo pipefail

usage='usage:
  store.sh root                              create ~/.pivo if missing; print it
  store.sh mkdir <path>                      create ~/.pivo/<path> if missing; print it
  store.sh find <mode> <parent> <query>      print dirs directly in ~/.pivo/<parent> whose
                                             name matches; exit 1 if none
                                             mode: exact | prefix | suffix | approx
  store.sh lock <file> <owner>               exit 0: acquired; exit 1: held, prints "<owner> <time>"
  store.sh unlock <file> <owner> [--force]   exit 0: released; exit 1: not yours, prints holder
<path>/<parent>: relative to ~/.pivo, "/"-separated, no "." or ".." parts ("." alone is the root)
exit 2: bad usage or invalid path'

root="$HOME/.pivo"

die() { echo "store.sh: $2" >&2; exit "$1"; }

# A path stays inside the root: relative, no empty, ".", ".." or "-"-leading parts.
valid_path() {
  local p="$1" part
  [[ -n "$p" && "$p" != /* ]] || return 1
  local -a parts
  IFS=/ read -ra parts <<< "$p"
  [[ "$p" != */ ]] || return 1
  for part in "${parts[@]}"; do
    [[ -n "$part" && "$part" != . && "$part" != .. && "$part" != -* ]] || return 1
  done
}

# approx: case and separators (- _ . space) ignored, and every word of the
# query must appear in the name, in any order: "Login fix" finds QWE-1-fix-login.
approx_match() {
  local name query word
  name="$(tr '[:upper:]' '[:lower:]' <<< "$1" | tr -c '[:alnum:]\n' ' ')"
  query="$(tr '[:upper:]' '[:lower:]' <<< "$2" | tr -c '[:alnum:]\n' ' ')"
  name="${name// /}"
  for word in $query; do
    [[ "$name" == *"$word"* ]] || return 1
  done
}

case "${1:-}" in
  root)
    mkdir -p "$root"
    echo "$root"
    ;;
  mkdir)
    valid_path "${2:-}" || die 2 "invalid path '${2:-}': want a relative path inside ~/.pivo, e.g. work/fix-login"
    mkdir -p "$root/$2"
    echo "$root/$2"
    ;;
  find)
    mode="${2:-}" parent="${3:-}" q="${4:-}"
    [[ "$mode" =~ ^(exact|prefix|suffix|approx)$ ]] || die 2 "invalid mode '$mode': want exact, prefix, suffix or approx"
    [[ "$parent" == . ]] || valid_path "$parent" || die 2 "invalid parent '$parent'"
    [[ -n "$q" && "$q" != */* ]] || die 2 "invalid query '$q': want a non-empty name without '/'"
    [[ -n "$(tr -d -c '[:alnum:]' <<< "$q")" || "$mode" != approx ]] || die 2 "approx query '$q' has no letters or digits"
    dir="$root"; [[ "$parent" == . ]] || dir="$root/$parent"
    found=1
    for d in "$dir"/*; do
      [[ -d "$d" ]] || continue
      name="${d##*/}"
      case "$mode" in
        exact)  [[ "$name" == "$q" ]] ;;
        prefix) [[ "$name" == "$q"* ]] ;;
        suffix) [[ "$name" == *"$q" ]] ;;
        approx) approx_match "$name" "$q" ;;
      esac || continue
      echo "$d"
      found=0
    done
    exit "$found"
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
