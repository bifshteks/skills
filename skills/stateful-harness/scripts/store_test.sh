#!/usr/bin/env bash
# Tests for store.sh, observed through stdout, exit code and the filesystem
# under a throwaway HOME. Run: skills/stateful-harness/scripts/store_test.sh
set -u

STORE="$(cd "$(dirname "$0")" && pwd)/store.sh"
failures=0

fail() { echo "FAIL ${FUNCNAME[1]}: $*"; failures=$((failures + 1)); }

# Each test runs in its own HOME, so ~/.pivo starts absent.
fresh_home() { HOME="$(mktemp -d)"; export HOME; }

test_root_creates_storage_root_and_prints_it() {
  fresh_home
  out="$("$STORE" root)" || fail "exit $?"
  [[ "$out" == "$HOME/.pivo" ]] || fail "printed '$out'"
  [[ -d "$HOME/.pivo" ]] || fail "~/.pivo not created"
}

test_dir_creates_named_directory_and_prints_it() {
  fresh_home
  for name in QWE-123-create-stateful-harness-skill create-stateful-harness-skill; do
    out="$("$STORE" dir "$name")" || fail "$name: exit $?"
    [[ "$out" == "$HOME/.pivo/$name" ]] || fail "$name: printed '$out'"
    [[ -d "$HOME/.pivo/$name" ]] || fail "$name: not created"
  done
}

test_dir_rejects_invalid_names_without_creating_anything() {
  fresh_home
  for name in "" Create-Harness QWE-123 qwe-123-x/y ../escape foo_bar -foo foo- foo--bar; do
    "$STORE" dir "$name" >/dev/null 2>&1
    code=$?
    [[ $code == 2 ]] || fail "'$name': exit $code, want 2"
  done
  [[ -z "$(ls -A "$HOME/.pivo" 2>/dev/null)" ]] || fail "created: $(ls -A "$HOME/.pivo")"
  [[ ! -e "$HOME/escape" ]] || fail "escaped ~/.pivo"
}

test_find_lists_directories_by_ticket_or_slug() {
  fresh_home
  mkdir -p "$HOME/.pivo"/{QWE-123-api-spike,QWE-123-migration-plan,QWE-1234-other,fix-login,ABC-9-fix-login,fix-login-v2}
  touch "$HOME/.pivo/QWE-123-notes.md"

  out="$("$STORE" find QWE-123)" || fail "ticket: exit $?"
  want="$HOME/.pivo/QWE-123-api-spike
$HOME/.pivo/QWE-123-migration-plan"
  [[ "$out" == "$want" ]] || fail "ticket: got '$out'"

  out="$("$STORE" find fix-login)" || fail "slug: exit $?"
  want="$HOME/.pivo/ABC-9-fix-login
$HOME/.pivo/fix-login"
  [[ "$out" == "$want" ]] || fail "slug: got '$out'"
}

test_find_exits_1_when_nothing_matches() {
  fresh_home
  out="$("$STORE" find QWE-999)"
  code=$?
  [[ $code == 1 ]] || fail "exit $code, want 1"
  [[ -z "$out" ]] || fail "printed '$out'"
}

test_lock_goes_to_first_claimant_and_reports_holder_to_second() {
  fresh_home
  f="$("$STORE" dir fix-login)/plan.md"

  out="$("$STORE" lock "$f" "subagent api")" || fail "first: exit $?"
  [[ -z "$out" ]] || fail "first printed '$out'"
  [[ "$(cat "$f.lock")" =~ ^subagent\ api\ [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]] \
    || fail "lock holds '$(cat "$f.lock")'"

  holder="$(cat "$f.lock")"
  out="$("$STORE" lock "$f" other 2>/dev/null)"
  code=$?
  [[ $code == 1 ]] || fail "second: exit $code, want 1"
  [[ "$out" == "$holder" ]] || fail "second printed '$out', want '$holder'"
  [[ "$(cat "$f.lock")" == "$holder" ]] || fail "second overwrote the lock"
}

test_lock_has_exactly_one_winner_under_contention() {
  fresh_home
  f="$("$STORE" dir fix-login)/plan.md"
  codes="$(mktemp -d)"
  for i in 1 2 3 4 5 6 7 8 9 10; do
    ( "$STORE" lock "$f" "agent-$i" >/dev/null 2>&1; echo $? > "$codes/$i" ) &
  done
  wait
  winners="$(grep -lx 0 "$codes"/* | wc -l | tr -d ' ')"
  [[ "$winners" == 1 ]] || fail "$winners winners, want 1"
}

test_unlock_releases_only_own_lock() {
  fresh_home
  f="$("$STORE" dir fix-login)/plan.md"
  "$STORE" lock "$f" "subagent api" || fail "lock: exit $?"
  holder="$(cat "$f.lock")"

  out="$("$STORE" unlock "$f" other 2>/dev/null)"
  code=$?
  [[ $code == 1 ]] || fail "other: exit $code, want 1"
  [[ "$out" == "$holder" ]] || fail "other printed '$out', want '$holder'"
  [[ -e "$f.lock" ]] || fail "other removed the lock"

  "$STORE" unlock "$f" "subagent api" || fail "owner: exit $?"
  [[ ! -e "$f.lock" ]] || fail "owner left the lock"
}

test_unlock_force_releases_any_lock() {
  fresh_home
  f="$("$STORE" dir fix-login)/plan.md"
  "$STORE" lock "$f" crashed-agent || fail "lock: exit $?"
  "$STORE" unlock "$f" rescuer --force || fail "force: exit $?"
  [[ ! -e "$f.lock" ]] || fail "force left the lock"
}

test_unlock_without_lock_reports_not_held() {
  fresh_home
  f="$("$STORE" dir fix-login)/plan.md"
  out="$("$STORE" unlock "$f" me 2>/dev/null)"
  code=$?
  [[ $code == 1 ]] || fail "exit $code, want 1"
  [[ -z "$out" ]] || fail "printed '$out'"
}

test_unknown_subcommand_prints_usage_and_exits_2() {
  fresh_home
  for args in "" "bogus"; do
    err="$("$STORE" $args 2>&1 >/dev/null)"
    code=$?
    [[ $code == 2 ]] || fail "'$args': exit $code, want 2"
    [[ "$err" == *usage* ]] || fail "'$args': stderr '$err'"
  done
}

for t in $(declare -F | awk '{print $3}' | grep '^test_'); do "$t"; done

if ((failures)); then echo "$failures failed"; exit 1; fi
echo "all passed"
