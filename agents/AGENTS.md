# Personal Workflow Instructions

**CRITICAL**: Use jj (Jujutsu) for version control, NOT git.

## Version Control

**Do NOT include co-authoring attribution in commits.**

Custom jj commands available:
- `jj pr` - Create pull request
- `jj sync` - Sync with remote and rebase  
- `jj start <name>` - Start new feature

### The Squash Workflow

This environment uses the [squash workflow](https://steveklabnik.github.io/jujutsu-tutorial/real-world-workflows/the-squash-workflow.html): an undescribed, empty commit floats at `@` as a working area. Changes accumulate there and are squashed into parent commits with `jj squash`.

**DO NOT panic when seeing changes in `@`**:
- This is the normal working state — not a mistake
- DO NOT automatically `jj describe` the current commit
- DO NOT try to split, clean up, or "fix" the working copy
- Just edit files — changes accumulate in `@`
- Only `jj squash` or `jj describe` when explicitly instructed

If unsure about commit structure, ask before modifying.

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
