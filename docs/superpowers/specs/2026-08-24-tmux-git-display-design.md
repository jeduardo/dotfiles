# Tmux Git Display Restoration Design

## Goal

Restore the local-repository Git status beside the current-path widget in the
Tokyo Night tmux status bar.

## Configuration

Set `@tokyo-night-tmux_show_git` to `1` in `dot_tmux.conf.tmpl` and add the
Tokyo Night `git-status.sh` command back to the managed `status-right` fragment
after the existing path widget.

Keep the 15-second `status-interval`. Continue excluding battery, music,
network speed, remote Git statistics, date/time, and hostname commands from the
managed status bar.

The shared fragment remains sourced after plugin and theme initialization, so
normal startup and macOS appearance changes produce the same path-and-Git
layout.

## Verification

- Render the managed files with chezmoi and validate the generated tmux syntax.
- Assert that `status-right` contains exactly the path and local Git widget
  commands and no excluded widget commands.
- If a tmux server is running, reload the configuration and inspect the live
  `status-right` value.
- Run `git diff --check`.
