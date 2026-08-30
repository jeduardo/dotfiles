# Codex Live Terminal Theme Design

## Problem

Ghostty updates its terminal palette when macOS switches between dark and light
appearance. tmux updates its own theme as well, but a running Codex TUI retains
the composer background it derived from the terminal colours at startup. After
an appearance change, that stale background can have insufficient contrast.

The shell receives `COLORTERM=truecolor` from Ghostty, and tmux preserves it for
new panes. Codex therefore selects a true-colour composer background and caches
the resulting RGB value instead of continuing to use the terminal's live default
background.

## Design

Add `private_dot_local/bin/executable_codex`, ported from `dotfiles-work`. Because
`~/.local/bin` appears first in `PATH`, this executable becomes the user-facing
`codex` command.

The wrapper will:

1. Build a search path that excludes its own physical directory, preventing
   recursive invocation.
2. Find the real Codex executable in the remaining `PATH`.
3. Report an error and exit with status 127 when no real executable exists.
4. Unset `COLORTERM` only for Codex, preserving true-colour support for every
   other terminal application.
5. Set `TERM=tmux` when running inside tmux and `TERM=xterm` otherwise.
6. Replace itself with the real Codex process while forwarding arguments and
   preserving Codex's exit status.

Advertising basic ANSI colour support makes Codex use the terminal's default
background for the composer while retaining ANSI accents. Ghostty can then
change that default background live when the system appearance changes.

## Scope

No Ghostty, tmux, shell, or system appearance notification configuration will
change. Existing running Codex processes must be restarted once to begin using
the wrapper; subsequent Ghostty palette changes will not require restarting
Codex.

## Verification

A temporary fake downstream `codex` executable will record its environment and
arguments. Verification will cover:

- `COLORTERM` is absent in the downstream process.
- `TERM` is `tmux` when `TMUX` is set.
- `TERM` is `xterm` when `TMUX` is absent.
- Arguments are forwarded unchanged.
- The wrapper skips itself and resolves the downstream executable.
- A missing downstream executable produces status 127 and a clear error.

Finally, `chezmoi execute-template` and `chezmoi diff` will confirm that the
source file is valid and deploys to `~/.local/bin/codex` with executable mode.
