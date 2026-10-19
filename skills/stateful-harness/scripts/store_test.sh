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

test_mkdir_creates_path_under_root_and_prints_it() {
  fresh_home
  for path in fix-login work/QWE-123-anything "wt/repo/Some Name_1.x"; do
    out="$("$STORE" mkdir "$path")" || fail "$path: exit $?"
    [[ "$out" == "$HOME/.pivo/$path" ]] || fail "$path: printed '$out'"
    [[ -d "$HOME/.pivo/$path" ]] || fail "$path: not created"
  done
}

test_mkdir_rejects_paths_leaving_root_without_creating_anything() {
  fresh_home
  for path in "" / /tmp/x .. ../escape work/../../escape . ./x work/ work//x -rf; do
    "$STORE" mkdir "$path" >/dev/null 2>&1
    code=$?
    [[ $code == 2 ]] || fail "'$path': exit $code, want 2"
  done
  [[ -z "$(ls -A "$HOME/.pivo" 2>/dev/null)" ]] || fail "created: $(ls -A "$HOME/.pivo")"
  [[ ! -e "$HOME/escape" && ! -e /tmp/x ]] || fail "escaped ~/.pivo"
}

# Fixture: dirs in ~/.pivo/work, plus a file and a nested dir that must never match.
seed_work() {
  mkdir -p "$HOME/.pivo/work"/{QWE-123-api-spike,QWE-123-migration-plan,QWE-1234-other,fix-login,ABC-9-fix-login,fix-login-v2}
  mkdir -p "$HOME/.pivo/work/fix-login/QWE-123-nested"
  touch "$HOME/.pivo/work/QWE-123-notes.md"
}

# find_is <mode> <query> <expected names in work/, sorted, space-separated>
find_is() {
  local out want="" n
  out="$("$STORE" find "$1" work "$2")" || fail "$1 '$2': exit $?"
  for n in $3; do want+="$HOME/.pivo/work/$n"$'\n'; done
  [[ "$out" == "${want%$'\n'}" ]] || fail "$1 '$2': got '$out'"
}

test_find_exact() {
  fresh_home; seed_work
  find_is exact fix-login "fix-login"
}

test_find_prefix() {
  fresh_home; seed_work
  find_is prefix QWE-123- "QWE-123-api-spike QWE-123-migration-plan"
  find_is prefix QWE-123 "QWE-123-api-spike QWE-123-migration-plan QWE-1234-other"
}

test_find_suffix() {
  fresh_home; seed_work
  find_is suffix -fix-login "ABC-9-fix-login"
  find_is suffix fix-login "ABC-9-fix-login fix-login"
}

test_find_approx_ignores_case_separators_and_word_order() {
  fresh_home; seed_work
  find_is approx "Login fix" "ABC-9-fix-login fix-login fix-login-v2"
  find_is approx migration_PLAN "QWE-123-migration-plan"
  find_is approx qwe123 "QWE-123-api-spike QWE-123-migration-plan QWE-1234-other"
}

test_find_in_root_and_nested_parent() {
  fresh_home; seed_work
  out="$("$STORE" find exact . work)" || fail "root: exit $?"
  [[ "$out" == "$HOME/.pivo/work" ]] || fail "root: got '$out'"
  out="$("$STORE" find prefix work/fix-login QWE)" || fail "nested: exit $?"
  [[ "$out" == "$HOME/.pivo/work/fix-login/QWE-123-nested" ]] || fail "nested: got '$out'"
}

test_find_exits_1_when_nothing_matches() {
  fresh_home; seed_work
  for args in "exact work QWE-999" "prefix nowhere x" "approx work zzz"; do
    out="$("$STORE" find $args)"
    code=$?
    [[ $code == 1 ]] || fail "'$args': exit $code, want 1"
    [[ -z "$out" ]] || fail "'$args': printed '$out'"
  done
}

test_find_rejects_bad_arguments() {
  fresh_home; seed_work
  for args in "" "fuzzy work x" "exact ../x y" "exact work" "exact work a/b" "approx work ---"; do
    "$STORE" find $args >/dev/null 2>&1
    code=$?
    [[ $code == 2 ]] || fail "'$args': exit $code, want 2"
  done
}

test_lock_goes_to_first_claimant_and_reports_holder_to_second() {
  fresh_home
  f="$("$STORE" mkdir work/fix-login)/plan.md"

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
  f="$("$STORE" mkdir work/fix-login)/plan.md"
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
  f="$("$STORE" mkdir work/fix-login)/plan.md"
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
  f="$("$STORE" mkdir work/fix-login)/plan.md"
  "$STORE" lock "$f" crashed-agent || fail "lock: exit $?"
  "$STORE" unlock "$f" rescuer --force || fail "force: exit $?"
  [[ ! -e "$f.lock" ]] || fail "force left the lock"
}

test_unlock_without_lock_reports_not_held() {
  fresh_home
  f="$("$STORE" mkdir work/fix-login)/plan.md"
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
