# bin/ script reference

Scripts in this repo. All are POSIX-safe bash unless noted.

---

## `agent-guard`

Claude Code `PreToolUse` hook. Sandboxes agents running in a jj agent workspace.

- **Main workspace** (`.jj/repo` is a directory) → pass through unchanged.
- **Agent workspace** (`.jj/repo` is a file) → file-edit tools must target a path inside the workspace; outward-facing bash commands (push, PR mutations, cloud deletes, publishes, DB DDL, recursive deletes outside the workspace) require explicit user approval.

**Usage:** Set as a `PreToolUse` hook in `claude/settings.json`. Not called directly.

**Dependencies:** `jj`, `jq`. Logs to `$AGENT_GUARD_LOG` (default `/tmp/agent-guard.log`).

---

## `herdr-jj`

Create, attach to, and remove jj-workspace-backed agent sessions inside herdr.

Each agent gets its own jj workspace so parallel agents never touch each other's files. herdr owns the UI; this script only manages jj workspaces and agent launch.

**Usage:**

```
herdr-jj new                                   # interactive: pick repo → pick/name work → pick model
herdr-jj new --repo <path> --name <name>       # scripted
             [--prompt <text>]                 # submit an initial prompt non-interactively
             [--model opus|sonnet|haiku]        # model tier shorthand
             [--agent <cmd>]                   # override agent command entirely
herdr-jj rm  [path]                            # forget workspace + delete checkout + close herdr ws
herdr-jj tidy [repo]                           # sweep dead workspaces and divergent commits
```

- `new` is idempotent: an existing workspace name attaches rather than fails.
- Workspaces live at `$HERDR_JJ_ROOT` (default `~/.herdr/workspaces/<repo>/<name>`).
- Agent command defaults to `$HERDR_JJ_AGENT` (default `claude --dangerously-skip-permissions`).
- `rm` without a path falls back to closing the current herdr workspace when not in an agent workspace.

**Dependencies:** `herdr`, `jj`, `jq`, `fzf` (interactive mode), `mise` (optional, for tool trust).

**Interactions:** Works with `agent-guard` — uses the same `.jj/repo` file/directory heuristic to distinguish main from agent workspaces.

---

## `herdr-url-picker`

Pick a URL from the current pane's content and open it in the browser.

Reads both the visible screen (alt-screen / TUI apps) and recent scrollback. Deduplicates and presents URLs in reverse order via fzf.

**Usage:** Bound to a herdr keybinding. Runs as a popup. Not called directly.

**Dependencies:** `herdr`, `fzf`, `python3`, `open` (macOS).

---

## `jj-float`

Rebase local/WIP commits to the top of `@` so they stay out of pushes.

If `local()` commits are already in `@`'s ancestry, extracts the non-local commits first, then floats the local ones on top.

**Usage:**

```
jj-float
```

No arguments. Exits cleanly if there are no `local()` commits.

**Dependencies:** `jj`.

---

## `jj-status-popup`

Show `jj status` in a herdr popup and wait for a keypress.

**Usage:** Bound to a herdr keybinding. Runs as a popup. Not called directly.

**Dependencies:** `jj`.

---

## `jj-workflow`

Non-interactive jj workflow commands. Exports `JJ_EDITOR=true` and `GH_PROMPT_DISABLED=1` so nothing hangs waiting for an editor or prompt.

Exposed as `jj pr`, `jj pr-edit`, `jj sync`, and `jj start` via shims.

**Usage:**

```
jj-workflow sync                               # fetch refs from origin
jj-workflow start                              # new empty commit on top of main@origin
jj-workflow pr [-r <rev>] [--body <text>] [--draft]
                                               # create or update a PR for the current change
jj-workflow pr-edit -n <number> [--title <text>] [--body <text>]
                                               # edit title/body of an existing PR
```

`pr` automatically: rebases onto `main@origin`, finds the nearest non-empty described commit, moves the head bookmark there, pushes, and opens the PR in the browser. After publishing it creates a new empty working commit.

`pr-edit` derives the GitHub repo from the jj origin remote, so it works in jj workspaces where there is no `.git` directory (unlike `gh pr edit`).

**Dependencies:** `jj`, `gh`.
