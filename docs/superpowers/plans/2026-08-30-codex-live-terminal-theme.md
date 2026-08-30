# Codex Live Terminal Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Codex composer follow Ghostty's live dark/light palette changes by launching Codex with basic ANSI colour capability.

**Architecture:** A chezmoi-managed `~/.local/bin/codex` wrapper shadows Homebrew's Codex executable. It excludes its own directory while resolving the real executable, adjusts terminal capability variables only for Codex, and uses `exec` to preserve arguments and exit status.

**Tech Stack:** Bash 3-compatible shell scripting, chezmoi, ShellCheck

---

### Task 1: Add the Codex Wrapper

**Files:**
- Create: `private_dot_local/bin/executable_codex`

- [ ] **Step 1: Port the wrapper from `dotfiles-work`**

Add the approved wrapper verbatim from
`dot_local/bin/executable_codex` in `jeduardo/dotfiles-work`.

- [ ] **Step 2: Run static shell validation**

Run: `shellcheck private_dot_local/bin/executable_codex`

Expected: exit status 0 with no diagnostics.

- [ ] **Step 3: Confirm the port is exact**

Run:

```bash
diff -u \
  <(gh api repos/jeduardo/dotfiles-work/contents/dot_local/bin/executable_codex --jq .content | base64 -d) \
  private_dot_local/bin/executable_codex
```

Expected: exit status 0 with no diff.

- [ ] **Step 4: Commit the wrapper**

```bash
git add private_dot_local/bin/executable_codex
git commit -m "fix(codex): follow live terminal theme"
```

### Task 2: Deploy and Verify Through chezmoi

**Files:**
- Source: `private_dot_local/bin/executable_codex`
- Deploy: `~/.local/bin/codex`

- [ ] **Step 1: Preview the target from the worktree source**

Run: `chezmoi --source "$PWD" diff -- ~/.local/bin/codex`

Expected: a new executable `~/.local/bin/codex` containing the wrapper.

- [ ] **Step 2: Apply only the wrapper target**

Run: `chezmoi --source "$PWD" apply -- ~/.local/bin/codex`

Expected: exit status 0 with no diagnostics.

- [ ] **Step 3: Verify command resolution and executable mode**

Run: `zsh -ic 'which -a codex'; ls -l ~/.local/bin/codex`

Expected: the interactive shell loads `.zshrc`, `~/.local/bin/codex` appears
before `/opt/homebrew/bin/codex`, and its mode is executable.

- [ ] **Step 4: Verify the installed Codex delegates through the wrapper**

Run: `COLORTERM=truecolor TMUX=/tmp/tmux ~/.local/bin/codex --version`

Expected: exit status 0 and the installed Codex version string.

- [ ] **Step 5: Run final checks**

Run: `shellcheck private_dot_local/bin/executable_codex && git diff --check && git status --short`

Expected: ShellCheck passes, `git diff --check` prints nothing, and the status contains no unexpected changes.
