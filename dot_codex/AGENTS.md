# Git commits

- Never add AI harnesses or models as co-authors in git commits or pull
  requests. Do not add `Co-Authored-By:` trailers for Claude, Claude Code,
  or any other AI tool or model, and do not add "Generated with"
  attribution lines.
- Only run `git push` when I ask you to push in that conversation. A
  request to commit is not a request to push. Approval to push once does
  not cover later pushes.

# GitHub Actions runs

- When you start or rerun a GitHub Actions run, give me the full URL of
  the run, for example `https://github.com/OWNER/REPO/actions/runs/ID`.
  Get it with `gh run list --workflow NAME -L 1 --json url`.
- Write the URL as plain text on its own line, with no backticks and no
  link text, so the terminal shows it in full and I can click it.

# Code comments

- Choose clear function and variable names so the code explains itself.
  Rename before you add a comment.
- Add a comment only when the code cannot say it: a workaround or a
  non-obvious external constraint. Never describe what the next line does.
- Never explain the reason behind code in a comment. Don't write comments
  like "this method does X because of Y".
- Hard limits for new comments, including in YAML and other config files:
  - A function's doc comment is 1 line.
  - Any other comment is at most 2 lines.
  - If you need more than 2 lines, rewrite the code or drop detail. Do not
    write a 3 or 4 line comment.

# Go

- Write Go tests with Ginkgo.

# Line wrapping

- When writing Markdown or code in any language other than Go, wrap lines
  at 80 columns.
- Don't wrap GitHub issues, PR descriptions, or comments. Write each
  paragraph as one line and let GitHub wrap it.

# Writing style

- Use plain words. Don't invent hyphenated compounds or new terms to
  describe something. Say what it does in a short phrase instead.
- Use a term only if the product, the code, or the reader already uses it.
- Avoid technical or academic jargon in prose and comments, for example
  invariant, idempotent, orthogonal, semantics, canonical, deterministic,
  surface (as a verb). Describe the behaviour in everyday words instead.
- No em dashes or en dashes in prose. Use a full stop, comma, colon, or
  parentheses.
- Avoid semicolons. Split the sentence in two.
- Use the Oxford comma: put a comma before "and" or "or" in a list of
  three or more items ("red, white, and blue").
- One idea per sentence. Prefer short sentences and active voice.
- No "not X, but Y" contrasts, forced lists of three, or one-line closers
  that repeat the point.
- Don't tell the reader something is important ("that's why it matters",
  "this is key", "this is crucial"). State the consequence instead.
- No inflated words: pivotal, crucial, robust, seamless, leverage, delve,
  showcase, landscape, underscore.
- No filler: just, simply, obviously, it's worth noting.
- Bold only for real UI labels or warnings, not for decoration.
- Use one name for one thing. Don't switch to synonyms for variety.
- Don't end a section with a summary of what it just said.
