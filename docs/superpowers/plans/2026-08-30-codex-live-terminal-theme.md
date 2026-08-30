# Codex Live Terminal Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Codex composer follow Ghostty's live dark/light palette changes by launching Codex with basic ANSI colour capability.

**Architecture:** A chezmoi-managed `~/.local/bin/codex` wrapper shadows Homebrew's Codex executable. It excludes its own directory while resolving the real executable, limits the environment only for Codex, and then uses `exec` so arguments and exit status remain transparent.

**Tech Stack:** Bash 3-compatible shell scripting, chezmoi, pure Bash integration test, ShellCheck

---

### Task 1: Add a Failing Wrapper Integration Test

**Files:**
- Create: `tests/executable_codex_test.sh`
- Create: `tests/fixtures/fake_codex`
- Test: `tests/executable_codex_test.sh`

- [ ] **Step 1: Add the downstream Codex test fixture**

```bash
#!/bin/bash

if [[ -n "${COLORTERM+x}" ]]; then
  printf 'COLORTERM_SET=true\n'
else
  printf 'COLORTERM_SET=false\n'
fi
printf 'TERM=%s\n' "${TERM-}"
printf 'ARG_COUNT=%s\n' "$#"
argument_number=1
for argument in "$@"; do
  printf 'ARG_%s=%s\n' "$argument_number" "$argument"
  argument_number=$((argument_number + 1))
done
exit "${FAKE_CODEX_EXIT:-0}"
```

- [ ] **Step 2: Write the failing integration test**

```bash
#!/bin/bash

set -eu

repository_root="$(cd "$(dirname "$0")/.." && pwd -P)"
wrapper="${repository_root}/private_dot_local/bin/executable_codex"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

wrapper_directory="${test_root}/wrapper"
downstream_directory="${test_root}/downstream"
mkdir -p "$wrapper_directory" "$downstream_directory"

if [[ ! -f "$wrapper" ]]; then
  echo "FAIL: missing wrapper: $wrapper" >&2
  exit 1
fi

cp "$wrapper" "${wrapper_directory}/codex"
chmod +x "${wrapper_directory}/codex"

cp "${repository_root}/tests/fixtures/fake_codex" "${downstream_directory}/codex"
chmod +x "${downstream_directory}/codex"

assert_contains() {
  local output="$1"
  local expected="$2"
  if [[ "$output" != *"$expected"* ]]; then
    printf 'FAIL: expected output to contain %q\nActual output:\n%s\n' "$expected" "$output" >&2
    exit 1
  fi
}

search_path="${wrapper_directory}:${downstream_directory}:/usr/bin:/bin"

inside_tmux_output="$({
  PATH="$search_path" COLORTERM=truecolor TMUX=/tmp/tmux \
    "${wrapper_directory}/codex" "hello world" --version
})"
assert_contains "$inside_tmux_output" 'COLORTERM_SET=false'
assert_contains "$inside_tmux_output" 'TERM=tmux'
assert_contains "$inside_tmux_output" 'ARG_COUNT=2'
assert_contains "$inside_tmux_output" 'ARG_1=hello world'
assert_contains "$inside_tmux_output" 'ARG_2=--version'

outside_tmux_output="$({
  PATH="$search_path" COLORTERM=truecolor TMUX= \
    "${wrapper_directory}/codex" --help
})"
assert_contains "$outside_tmux_output" 'COLORTERM_SET=false'
assert_contains "$outside_tmux_output" 'TERM=xterm'

set +e
PATH="$search_path" FAKE_CODEX_EXIT=23 "${wrapper_directory}/codex" >/dev/null
actual_exit=$?
set -e
if [[ "$actual_exit" -ne 23 ]]; then
  echo "FAIL: expected downstream status 23, got $actual_exit" >&2
  exit 1
fi

set +e
missing_output="$(PATH="${wrapper_directory}:/usr/bin:/bin" "${wrapper_directory}/codex" 2>&1)"
missing_exit=$?
set -e
if [[ "$missing_exit" -ne 127 ]]; then
  echo "FAIL: expected missing-executable status 127, got $missing_exit" >&2
  exit 1
fi
assert_contains "$missing_output" 'codex: could not find the real Codex executable'

echo 'PASS: Codex wrapper environment and forwarding'
```

- [ ] **Step 3: Make the test and fixture executable**

Run: `chmod +x tests/executable_codex_test.sh tests/fixtures/fake_codex`

Expected: `ls -l tests/executable_codex_test.sh tests/fixtures/fake_codex` shows both files beginning with `-rwxr-xr-x`.

- [ ] **Step 4: Run the test and verify the expected failure**

Run: `tests/executable_codex_test.sh`

Expected: exit status 1 with `FAIL: missing wrapper: .../private_dot_local/bin/executable_codex`.

- [ ] **Step 5: Commit the failing test**

```bash
git add tests/executable_codex_test.sh tests/fixtures/fake_codex
git commit -m "test(codex): cover terminal capability wrapper"
```

### Task 2: Add the Codex Wrapper

**Files:**
- Create: `private_dot_local/bin/executable_codex`
- Test: `tests/executable_codex_test.sh`

- [ ] **Step 1: Add the minimal wrapper implementation**

```bash
#!/bin/bash
# Codex caches the terminal's default foreground/background colors at startup.
# When Ghostty follows the macOS appearance, Codex therefore keeps painting its
# composer with a blended RGB color derived from the previous theme.
#
# Advertising basic ANSI color support makes that blended background fall back
# to the terminal default while retaining Codex's ANSI accents. Ghostty can
# then update the composer background live when its theme changes.

set -e

wrapper_directory="$(cd "$(dirname "$0")" && pwd -P)"
search_path=""

old_ifs="$IFS"
IFS=:
for directory in $PATH; do
  [[ -n "$directory" ]] || directory="."
  [[ "$(cd "$directory" 2>/dev/null && pwd -P)" == "$wrapper_directory" ]] && continue
  if [[ -n "$search_path" ]]; then
    search_path="${search_path}:"
  fi
  search_path="${search_path}${directory}"
done
IFS="$old_ifs"

real_codex="$(PATH="$search_path" command -v codex 2>/dev/null || true)"
if [[ -z "$real_codex" ]]; then
  echo "codex: could not find the real Codex executable" >&2
  exit 127
fi

unset COLORTERM
if [[ -n "${TMUX:-}" ]]; then
  export TERM=tmux
else
  export TERM=xterm
fi
exec "$real_codex" "$@"
```

- [ ] **Step 2: Run the integration test and verify it passes**

Run: `tests/executable_codex_test.sh`

Expected: exit status 0 with `PASS: Codex wrapper environment and forwarding`.

- [ ] **Step 3: Run static shell validation**

Run: `shellcheck private_dot_local/bin/executable_codex tests/executable_codex_test.sh tests/fixtures/fake_codex`

Expected: exit status 0 with no diagnostics.

- [ ] **Step 4: Commit the implementation**

```bash
git add private_dot_local/bin/executable_codex
git commit -m "fix(codex): follow live terminal theme"
```

### Task 3: Deploy and Verify Through chezmoi

**Files:**
- Source: `private_dot_local/bin/executable_codex`
- Deploy: `~/.local/bin/codex`

- [ ] **Step 1: Preview the managed target**

Run: `chezmoi diff -- ~/.local/bin/codex`

Expected: a new executable `~/.local/bin/codex` containing the tested wrapper.

- [ ] **Step 2: Apply only the Codex wrapper target**

Run: `chezmoi apply -- ~/.local/bin/codex`

Expected: exit status 0 with no diagnostics.

- [ ] **Step 3: Verify command resolution and file mode**

Run: `zsh -lc 'which -a codex'; ls -l ~/.local/bin/codex`

Expected: `~/.local/bin/codex` appears before `/opt/homebrew/bin/codex`, and its mode is executable.

- [ ] **Step 4: Verify the real installed Codex still runs through the wrapper**

Run: `COLORTERM=truecolor TMUX=/tmp/tmux ~/.local/bin/codex --version`

Expected: exit status 0 and the installed Codex version string.

- [ ] **Step 5: Run final repository checks**

Run: `tests/executable_codex_test.sh && shellcheck private_dot_local/bin/executable_codex tests/executable_codex_test.sh tests/fixtures/fake_codex && git diff --check && git status --short`

Expected: tests and ShellCheck pass, `git diff --check` prints nothing, and the status contains no unexpected changes.
