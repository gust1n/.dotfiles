# Personal Workflow Instructions

**Writing style**: Use ASD-STE100 (Simplified Technical English). Short sentences. Active voice. One idea per sentence. Plain approved words. No marketing language.

**CRITICAL**: Use jj (Jujutsu) for version control, NOT git.

## Work Process

**For non-trivial features (especially in agent sessions)**:
1. **Plan** - Draft thorough implementation plan, confirm with user before coding
2. **Implement to completion** - Finish the entire feature, all edge cases, all files. Do NOT stop at 50% and ask for approval. Test everything you can without human assistance
3. **Verify** - Run tests and lint. Fix all failures. If tests/lint don't exist or can't run, document why
4. **Self-review** - Review all changes with staff engineer scrutiny, fix obvious flaws
5. **Present** - Only then report work as complete

Discuss "nice to haves" or unclear improvements rather than implementing them.
For simple requests, skip the ceremony and just execute.

## Version Control

Custom jj commands available:
- `jj pr` - Create or update a pull request (handles bookmark, push, and gh pr create)
- `jj sync` - Sync with remote and rebase  
- `jj start <name>` - Start new feature

**Creating a PR**: Always use `jj pr`. Do NOT manually create bookmarks, push, or call `gh pr create` — `jj pr` does all of this. It finds the correct commit to publish (skipping empty working commits), creates/moves the bookmark, pushes, and opens the PR.

```bash
# Basic — title comes from commit description's first line, body from the rest
jj pr

# With explicit body (use for detailed PR descriptions)
jj pr --body "## Summary
- Added foo
- Fixed bar

## Test plan
- Ran unit tests"

# Target a specific revision
jj pr -r @-

# Draft PR
jj pr --draft
```

The PR title is always the first line of the commit description. To set a good PR body, either write a multi-line commit description (lines after the first become the body) or pass `--body`.

### The Squash Workflow

This environment uses the [squash workflow](https://steveklabnik.github.io/jujutsu-tutorial/real-world-workflows/the-squash-workflow.html): an undescribed, empty commit floats at `@` as a working area. Changes accumulate there and are squashed into parent commits with `jj squash`.

**DO NOT panic when seeing changes in `@`**:
- This is the normal working state — not a mistake
- DO NOT automatically `jj describe` the current commit
- DO NOT try to split, clean up, or "fix" the working copy
- Just edit files — changes accumulate in `@`

**Creating commits**:
- You CAN create commits naturally as work completes (use `jj split` for multiple logical commits)
- Organize changes into clear, logical commits with good messages
- **NEVER push or create PRs unless explicitly instructed**
- When `@-` is immutable (e.g. `main@origin`), you cannot `jj squash` — use `jj describe` on `@` instead

**Organizing accumulated changes into multiple commits**:
```bash
# Use jj split to carve out logical commits
jj split file1 file2 -m "first commit message"
jj split file3 file4 -m "second commit message"
jj describe -m "final commit for remaining files"

# Re-establish empty working commit on top
jj new
```

After creating commits, always run `jj new` to maintain the squash workflow pattern.

### Never let jj open an editor

You have no interactive TTY, so any jj command that opens `$EDITOR` blocks until
the harness kills it at timeout. `JJ_EDITOR=true` is exported for agent sessions,
which stops the hang — but it does not always give the message you want, so still
pass the message explicitly:

| Command | Use |
|---|---|
| `jj squash` where **both** source and destination have descriptions | `jj squash --into <rev> --use-destination-message` |
| `jj describe` | always with `-m "..."` (or `--stdin`) |
| `jj commit` | always with `-m "..."` |
| `jj split` | always with explicit **paths** and `-m "..."` |

Two traps `JJ_EDITOR` does not cover:

- **`jj squash` with no flags concatenates both messages.** With `JJ_EDITOR=true`
  the editor is a no-op, so the destination silently keeps `dest msg\n\nwip: ...`
  — your throwaway `wip:` line ends up in the real commit message. Use
  `--use-destination-message` (keep the destination's) or `-m` (write a new one).
- **`jj split` with no paths opens the builtin TUI diff editor**, which is
  `ui.diff-editor`, not `JJ_EDITOR`. It fails fast (`Device not configured`)
  rather than hanging, but it will not work — always name the paths.

Path-scoped jj config (`--when.repositories`) does **not** apply inside secondary
workspaces, so it cannot be used to make agent checkouts non-interactive; the
environment variable is the mechanism.

## Workspace Isolation

You may be running inside a **jj workspace** — a second working copy of the repo,
typically at `~/.herdr/workspaces/<repo>/<name>/`. Detect it reliably:
```bash
jj workspace root   # Your working copy root, from any subdirectory
jj workspace list   # All workspaces; yours is the one marked @

# A secondary (agent) workspace stores .jj/repo as a FILE; the main checkout
# stores it as a directory:
[ -f "$(jj workspace root)/.jj/repo" ] && echo "agent workspace" || echo "main checkout"
```

**Rules when inside a workspace:**
- Only modify files within your working copy — never `cd` to the parent repo or other workspaces
- Do NOT rebase onto, modify, or interact with commits from other workspaces
- Do NOT run `jj workspace forget` — lifecycle is managed externally (`herdr-jj rm`)
- Your scope is `@` and its ancestors back to your fork point — nothing else
- Use `jj log -r 'ancestors(@, 10)'` to orient yourself, not broad queries across all branches

A `PreToolUse` guard enforces most of this: edits outside your workspace, pushes,
PR mutations and outward-facing destructive commands are blocked. If something is
denied, that is the guard doing its job — do not work around it, tell the user.

If you need something from another branch (e.g. a type definition landed on main), rebase your work:
```bash
jj rebase -d main@origin
```

## Snapshot Discipline

**CRITICAL**: On data loss, recover from `jj op log` — never reimplement from scratch.

Agent hooks snapshot the working copy every turn. Search with:
```bash
jj op log                                    # Find operation ID
jj --at-op <op-id> diff                     # View diff at that point
jj --at-op <op-id> log -r @                 # View commit at that point
jj --at-op <op-id> file show <path>         # View file at that point
```

## Environment

- Shell: bash
- OS: macOS
- Tools: mise, tmux (C-a prefix), fzf, fd, rg, bat
