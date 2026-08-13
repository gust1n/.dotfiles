# Personal Workflow Instructions

**Writing style**: Use ASD-STE100 (Simplified Technical English). Short sentences. Active voice. One idea per sentence. Plain approved words. No marketing language.

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
- `jj sync` — Sync with remote and rebase.
- `jj start <name>` — Start new feature.

**Creating a PR**: Always use `jj pr`. Do NOT manually create bookmarks, push, or call `gh pr create`.

```bash
jj pr                  # title from commit description's first line
jj pr --body "..."     # explicit PR body
jj pr -r @-            # target a specific revision
jj pr --draft          # draft PR
```

The PR title is always the first line of the commit description.

### The Squash Workflow

An undescribed, empty commit floats at `@` as a working area. Changes accumulate there and are squashed into parent commits with `jj squash`.

Rules:
- Changes in `@` are normal — do NOT auto-describe or clean up the working copy.
- Create commits naturally as work completes; use `jj split` for multiple logical commits.
- **NEVER push or create PRs unless explicitly instructed.**
- When `@-` is immutable (e.g. `main@origin`), use `jj describe` on `@` instead of `jj squash`.
- After creating commits, run `jj new` to re-establish the empty working commit.

### Never let jj open an editor

No interactive TTY in agent sessions. Always pass messages explicitly:

| Command | Rule |
|---|---|
| `jj squash` (both sides described) | use `--use-destination-message` or `-m "..."` |
| `jj describe` | always `-m "..."` |
| `jj commit` | always `-m "..."` |
| `jj split` | always explicit **paths** and `-m "..."` |

Traps:
- `jj squash` with no flags concatenates both messages. Use `--use-destination-message`.
- `jj split` with no paths opens a TUI diff editor. Always name the paths.

## Workspace Isolation

You are likely inside a **jj workspace** at `~/.herdr/workspaces/<repo>/<name>/`.

Rules:
- Only modify files within your working copy.
- Do NOT rebase onto, modify, or interact with commits from other workspaces.
- Do NOT run `jj workspace forget` — lifecycle is managed externally.
- Your scope is `@` and its ancestors back to your fork point.
- Use `jj log -r 'ancestors(@, 10)'` to orient yourself.

If a guard denies a command, that is expected — tell the user, do not work around it.

To pull in upstream changes:
```bash
jj rebase -d main@origin
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
