# Tmux Status Widgets Design

## Goal

Configure the Tokyo Night tmux status bar to run and display only the current-path and local-repository Git status widgets.

## Design

Keep the Tokyo Night plugin unchanged. Add a shared tmux fragment at `private_dot_config/tmux/themes/tokyonight-status-right.conf` that overrides the global `status-right` value with only these two plugin commands, in this order:

1. `path-widget.sh #{pane_current_path}`
2. `git-status.sh #{pane_current_path}`

Source the shared fragment after TPM and the saved appearance theme are loaded in `dot_tmux.conf.tmpl`. Also source it after the Tokyo Night plugin runs in both appearance wrappers. This ordering prevents plugin initialization and later light/dark appearance changes from restoring the default seven-widget command list.

Omitting the unwanted commands entirely prevents tmux from launching their scripts; setting their visibility flags to zero would only suppress their output.

The separate GitHub/GitLab statistics (`wb-git-status`) widget is excluded. Installed plugin files remain unchanged.

## Verification

Before editing, a configuration assertion must fail because the generated `status-right` contains commands other than path and local Git. After editing:

- render the chezmoi templates and verify the shared fragment is sourced after every Tokyo Night plugin invocation;
- apply or source the rendered configuration safely;
- inspect tmux's live `status-right` and confirm that battery, music, network speed, remote Git statistics, date/time, and hostname widget commands are absent;
- verify that path and local Git status commands remain present.
