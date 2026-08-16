# Minimal Tmux Status Widgets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Tokyo Night run and display only its current-path and local-repository Git widgets in tmux.

**Architecture:** Store the minimal `status-right` definition in one managed tmux fragment. Source that fragment after Tokyo Night initializes during normal tmux startup and after either macOS appearance wrapper reruns the plugin, so no plugin lifecycle can restore the unwanted widget commands.

**Tech Stack:** tmux configuration, chezmoi templates, Zsh shell assertions

---

### Task 1: Add the durable minimal status definition

**Files:**
- Create: `private_dot_config/tmux/themes/tokyonight-status-right.conf`
- Modify: `dot_tmux.conf.tmpl`
- Modify: `private_dot_config/tmux/themes/tokyonight-storm.conf`
- Modify: `private_dot_config/tmux/themes/tokyonight-day.conf`
- Test: inline Zsh configuration assertions

- [ ] **Step 1: Run the pre-change assertion and verify it fails**

```zsh
fragment=private_dot_config/tmux/themes/tokyonight-status-right.conf
test -f "$fragment" && \
  test "$(rg -o '#\(' "$fragment" | wc -l | tr -d ' ')" = 2 && \
  rg -qF 'path-widget.sh #{pane_current_path}' "$fragment" && \
  rg -qF 'git-status.sh #{pane_current_path}' "$fragment" && \
  ! rg -q 'battery-widget|music-tmux-statusbar|netspeed|wb-git-status|datetime-widget|hostname-widget' "$fragment"
```

Expected: exit status `1` because the shared fragment does not exist.

- [ ] **Step 2: Create the shared fragment**

Create `private_dot_config/tmux/themes/tokyonight-status-right.conf` with:

```tmux
# Keep only inexpensive, locally useful Tokyo Night widgets.
set -g status-right "#($HOME/.tmux/plugins/tokyo-night-tmux/src/path-widget.sh #{pane_current_path})#($HOME/.tmux/plugins/tokyo-night-tmux/src/git-status.sh #{pane_current_path})"
```

- [ ] **Step 3: Source the fragment after every Tokyo Night initialization**

Append this line to `dot_tmux.conf.tmpl`, after the macOS saved-theme `if-shell` block at the end of the file:

```tmux

# Tokyo Night includes hidden widget commands in status-right; replace them
# after every plugin/theme initialization so tmux only launches path and Git.
source-file "$HOME/.config/tmux/themes/tokyonight-status-right.conf"
```

Append this line to both `private_dot_config/tmux/themes/tokyonight-storm.conf` and `private_dot_config/tmux/themes/tokyonight-day.conf`, after each file's `status-left` override:

```tmux

source-file "$HOME/.config/tmux/themes/tokyonight-status-right.conf"
```

- [ ] **Step 4: Run configuration assertions and verify they pass**

```zsh
fragment=private_dot_config/tmux/themes/tokyonight-status-right.conf
source_command='source-file "$HOME/.config/tmux/themes/tokyonight-status-right.conf"'

test "$(rg -o '#\(' "$fragment" | wc -l | tr -d ' ')" = 2 && \
  rg -qF 'path-widget.sh #{pane_current_path}' "$fragment" && \
  rg -qF 'git-status.sh #{pane_current_path}' "$fragment" && \
  ! rg -q 'battery-widget|music-tmux-statusbar|netspeed|wb-git-status|datetime-widget|hostname-widget' "$fragment" && \
  test "$(rg -cF "$source_command" dot_tmux.conf.tmpl)" = 1 && \
  test "$(rg -cF "$source_command" private_dot_config/tmux/themes/tokyonight-storm.conf)" = 1 && \
  test "$(rg -cF "$source_command" private_dot_config/tmux/themes/tokyonight-day.conf)" = 1 && \
  git diff --check
```

Expected: exit status `0` with no output.

- [ ] **Step 5: Apply the managed files and reload tmux**

```zsh
chezmoi apply -- \
  "$HOME/.tmux.conf" \
  "$HOME/.config/tmux/themes/tokyonight-status-right.conf" \
  "$HOME/.config/tmux/themes/tokyonight-storm.conf" \
  "$HOME/.config/tmux/themes/tokyonight-day.conf"
tmux source-file "$HOME/.tmux.conf"
```

Expected: both commands exit with status `0`.

- [ ] **Step 6: Verify the live tmux status contains only the intended widget commands**

```zsh
live_status=$(tmux show-options -gv status-right)
test "$(printf '%s\n' "$live_status" | rg -o '#\(' | wc -l | tr -d ' ')" = 2 && \
  printf '%s\n' "$live_status" | rg -qF 'path-widget.sh #{pane_current_path}' && \
  printf '%s\n' "$live_status" | rg -qF 'git-status.sh #{pane_current_path}' && \
  ! printf '%s\n' "$live_status" | rg -q 'battery-widget|music-tmux-statusbar|netspeed|wb-git-status|datetime-widget|hostname-widget'
```

Expected: exit status `0` with no output.

- [ ] **Step 7: Commit the configuration change**

```zsh
git add \
  dot_tmux.conf.tmpl \
  private_dot_config/tmux/themes/tokyonight-status-right.conf \
  private_dot_config/tmux/themes/tokyonight-storm.conf \
  private_dot_config/tmux/themes/tokyonight-day.conf
git commit -m "perf(tmux): run only path and git status widgets"
```

Expected: one commit containing only the four tmux configuration files.
