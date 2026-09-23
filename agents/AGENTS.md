# Personal Workflow Instructions

**Writing style**: Use ASD-STE100 (Simplified Technical English). Short sentences. Active voice. One idea per sentence. Plain approved words. No marketing language.

**Editing AGENTS.md files**: Be concise. State facts and rules, not explanations or reasoning. No babble, no filler, no restating what a command already says. Every extra sentence costs context and confuses the next agent. Bullets over paragraphs.

**Code comments**: Explain non-obvious *current* behavior for a future reader, nothing else. Never narrate discussion history, rejected alternatives, or what changed and why relative to a previous version — jj history already records that. If the code is self-explanatory, write no comment.
- Bad: "changed this since the retry approach was rejected"; "kept for backward compat with the old flow"; "per our discussion, using X instead of Y."
- Good: "retries capped at 3: the upstream API rate-limits above that, see docs.example.com/rate-limits."

**CRITICAL**: Use jj (Jujutsu) for version control, NOT git.

## Work Process

**For non-trivial features (especially in agent sessions)**:
1. **Plan** — Draft implementation plan, confirm with user before coding.
2. **Implement to completion** — Finish the entire feature. Do NOT stop partway and ask for approval. Test everything you can without human assistance.
3. **Verify** — Run tests and lint. Fix all failures.
4. **Self-review** — Review with staff engineer scrutiny. Fix obvious flaws.
5. **Present** — Only then report work as complete.

For simple requests, skip the ceremony and just execute.

## Version Control

Custom jj commands:
- `jj pr` — Create or update a pull request (bookmark + push + gh pr create).
- `jj pr-checks` — Wait for the PR's CI checks and report pass or fail.
- `jj pr-edit` — Edit the title or body of an existing PR. Use this instead of `gh pr edit`.
- `jj sync` — Sync with remote and rebase.
- `jj start <name>` — Start new feature.

`--help` on each command is complete. Do not read the `jj-workflow` source.

**Creating a PR**: Always use `jj pr`. Do NOT manually create bookmarks, push, or call `gh pr create` — `jj pr` handles the bookmark, the push and the PR together, and passes `--repo` so it works in a jj workspace with no `.git`.

```bash
jj pr                  # draft PR; title from the commit description's first line
jj pr --body "..."     # explicit PR body
jj pr -r @-            # target a specific revision
jj pr --no-draft       # ready for review — only when the user asks for that
```

- Drafts are the default. Only pass `--no-draft` when the user has said the work is ready.
- Works against `trunk()` (`main` or `master`).
- On failure it prints the `gh` error. Fix the cause. Do not fall back to raw `gh pr create`.
- The PR title is always the first line of the commit description.

**PR loop**: When the user asks for a PR:
1. Describe the commit. Run `jj pr`.
2. Run `jj pr-checks`. It can take many minutes: in Claude Code, run it in the background.
3. On a failure, read the logs with the `gh run view` command it prints. Fix the code, `jj squash` the fix into the PR commit, run `jj pr`, go to 2.
4. When it exits 0, report the PR URL to the user.

Agents may push only to draft PRs. `jj pr` refuses a PR that is ready for review; ask the user before you run `jj pr --allow-ready`.

**Editing an existing PR**: Always use `jj pr-edit`. Do NOT call `gh pr edit` directly — it fails in jj workspaces because there is no `.git` directory.

```bash
jj pr-edit --number 141 --body "..."   # update body
jj pr-edit --number 141 --title "..."  # update title
jj pr-edit --number 141 --title "..." --body "..."  # update both
```

### The Squash Workflow

An undescribed, empty commit floats at `@` as a working area. Changes accumulate there and are squashed into parent commits with `jj squash`.

Rules:
- Changes in `@` are normal — do NOT auto-describe or clean up the working copy.
- Create commits naturally as work completes; use `jj split` for multiple logical commits.
- **NEVER push or create PRs unless explicitly instructed.**
- When `@-` is immutable (e.g. `trunk()`), use `jj describe` on `@` instead of `jj squash`.
- After creating commits, run `jj new` to re-establish the empty working commit.

### Never let jj block on a prompt

Do not assume there is no TTY: some harnesses run tools in a PTY, so jj sees a
terminal and opens an editor or a pager that nobody can answer. Always pass
messages explicitly:

| Command | Rule |
|---|---|
| `jj squash` (both sides described) | use `--use-destination-message` or `-m "..."` |
| `jj describe` | always `-m "..."` |
| `jj commit` | always `-m "..."` |
| `jj split` | always explicit **paths** and `-m "..."` |

Traps:
- `jj squash` with no flags concatenates both messages. Use `--use-destination-message`.
- `jj split` with no paths opens a TUI diff editor. Always name the paths.
- jj ignores `PAGER`, so exporting `PAGER=cat` does nothing. A scope in
  `config/jj/config.toml` sets `paginate = "never"` for known agent
  environments; if jj still pages, add `--no-pager`.

## Workspace Isolation

You are likely inside a **jj workspace** at `~/.herdr/workspaces/<repo>/<name>/`.

Rules:
- Only modify files within your working copy.
- Do NOT rebase onto, modify, or interact with commits from other workspaces.
- Do NOT run `jj workspace forget` — lifecycle is managed externally.
- Your scope is `@` and its ancestors back to your fork point.
- Use `jj log -r 'ancestors(@, 10)'` to orient yourself.

If a guard denies a command, that is expected — tell the user, do not work around it.
`jj pr` to a draft runs without a prompt. Other pushes, `--no-draft` and `--allow-ready` prompt the user.

To pull in upstream changes:
```bash
jj rebase -d 'trunk()'
```

## Snapshot Discipline

**CRITICAL**: On data loss, recover from `jj op log` — never reimplement from scratch.

```bash
jj op log                             # find operation ID
jj --at-op <op-id> diff              # view diff at that point
jj --at-op <op-id> file show <path>  # view file at that point
```

## Environment

- Shell: bash
- OS: macOS
- Tools: mise, tmux (C-a prefix), fzf, fd, rg, bat
