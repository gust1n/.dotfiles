# Personal Workflow Instructions

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

**Do NOT include co-authoring attribution in commits.**

Custom jj commands available:
- `jj pr` - Create or update a pull request (handles bookmark, push, and gh pr create)
- `jj sync` - Sync with remote and rebase  
- `jj start <name>` - Start new feature

**Creating a PR**: Always use `jj pr`. Do NOT manually create bookmarks, push, or call `gh pr create` — `jj pr` does all of this. It finds the correct commit to publish (skipping empty working commits), creates/moves the bookmark, pushes, and opens the PR.

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

## Workspace Isolation

You are likely running inside a **jj workspace** (a subdirectory like `<repo>/.jj-workspaces/<name>/`). Detect with:
```bash
jj workspace list   # Shows all workspaces; your name is the current one
pwd                 # If path contains .jj-workspaces/ you're in one
```

**Rules when inside a workspace:**
- Only modify files within your working copy — never `cd` to the parent repo or other workspaces
- Do NOT rebase onto, modify, or interact with commits from other workspaces
- Do NOT run `jj workspace forget` — lifecycle is managed externally
- Your scope is `@` and its ancestors back to your fork point — nothing else
- Use `jj log -r 'ancestors(@, 10)'` to orient yourself, not broad queries across all branches

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
