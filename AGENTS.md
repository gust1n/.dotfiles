# Agent Management System

Parallel Claude Code agents, each in its own **jj workspace**, orchestrated by
**herdr**.

**See [PERSONAL.md](PERSONAL.md) for general workflow instructions (version control, tools, code style).**

## The idea

A jj *workspace* is a second working copy attached to the same repo. Each agent
gets one, so:

- Agents never overwrite each other's files, even working in the same repo.
- Your **main** checkout (`~/Code/<repo>`) stays yours — for reading code and
  hand-editing — and no agent lives there.
- Agents run `claude --dangerously-skip-permissions` (never stopping to ask),
  with `bin/agent-guard` keeping them inside their workspace.

herdr owns everything visual: workspaces, the sidebar, agent state icons, the
attention queue. This repo only supplies what herdr has no opinion about —
creating and forgetting jj workspaces — because herdr's built-in worktree
support is `git worktree`-based, which a jj repo won't track.

## Architecture

```
bin/herdr-jj    - jj workspace lifecycle: new (pick/attach) / rm / tidy
bin/agent-guard - PreToolUse hook: sandboxes agents to their workspace
config/herdr/config.toml - keybindings (popups → herdr-jj), sidebar, attention queue
claude/settings.json     - the single PreToolUse hook
agents/AGENTS.md         - shared agent instructions (→ ~/.claude/CLAUDE.md)
agents/skills/           - agent skills, linked into every agent (see below)
```

That's it. Agent state icons, stale detection, the status bar and session
switching are all herdr built-ins now — the six scripts and ~30 lines of
`tmux.conf` that used to do that are gone. tmux is a plain multiplexer again.

## Main workflow

1. `prefix+shift+a` — pick a repo, then pick or name the work.
2. herdr opens a workspace at that checkout and launches
   `claude --dangerously-skip-permissions`. Describe the task.
3. Repeat 3–5 times, then watch the sidebar. With
   `agent_panel_sort = "priority"`, agents needing you float to the top.
4. `prefix+alt+1..9` jumps straight to the Nth agent; `prefix+w` is the picker.
5. When work lands, `prefix+shift+d` removes that workspace (it warns first if
   there are unpushed commits).

### The picker

One ranked list, most likely first — the same popup starts new work and
reattaches to old:

```
+ new agent  (or type a name here)
● fix-auth              agent          ← running; selecting attaches
○ mise-oci-ci           workspace      ← on disk, no agent; reopens + --continue
  gust1n/push-abc       local · 3d     ← your bookmark; branches a workspace off it
  backevik/thing        origin · 2w    ← a colleague's; still reachable
```

Ranking beats filtering: a repo can have 150+ remote bookmarks (dependabot,
every colleague's branch), and a **local** bookmark is the signal that you've
touched something. So local sorts above remote, newest first, and nothing is
hidden — fzf substring matching keeps a colleague's branch one keystroke away.
Anything you type that matches nothing becomes a new workspace and bookmark.

A name that already has a workspace is shown once, as the workspace.

## Keybindings

Prefix is `ctrl+a`.

| Key | Does |
|---|---|
| `prefix+shift+a` | New agent, or attach to an existing workspace |
| `prefix+shift+d` | In an agent workspace: remove it. Elsewhere: close the workspace (native) |
| `prefix+shift+y` | Tidy: sweep dead workspaces and divergent commits |
| `prefix+w` | Workspace picker (herdr native) |
| `prefix+alt+1..9` | Focus the Nth agent (herdr native) |
| `prefix+g` | Goto (herdr native) |
| `prefix+b` | Toggle sidebar (herdr native) |

Only three keys are custom, and `shift+d` degrades to its native behaviour, so
everything else is stock herdr — `prefix+shift+n` for a new workspace,
`prefix+c` for a tab, `prefix+v` / `prefix+minus` to split.

## Just coding (no agent)

Nothing custom needed. Use native herdr — `prefix+shift+n` for a new workspace
at any directory, then work in your main checkout as usual. No jj workspace is
created, and `agent-guard` passes straight through in a main checkout, so your
own permissions are untouched. The picker is only for spawning or reattaching to
agents.

## CLI

```bash
herdr-jj new                    # interactive: repo → pick or name → launch/attach
herdr-jj new --repo /path --name fix-auth --prompt "..."   # scripted (/dispatch)
herdr-jj rm [path]              # forget + delete + close (defaults to the current one)
herdr-jj tidy [repo]            # sweep dead workspaces / divergent commits
```

`new` is idempotent: given a name that already has a workspace it attaches
instead of failing — focusing it if an agent is live, or reopening it with
`--continue` if not. That's why there's no separate `resume`/`ls`; the picker
shows the state and one code path handles both.

Useful herdr natives:

```bash
herdr agent list                # every agent + state, as JSON
herdr agent read <pane>         # what an agent's terminal shows
herdr agent prompt <pane> "..." # send a follow-up
herdr agent wait <pane> --until idle   # block until it's done
```

## Layout

Checkouts live outside the repos, at:

```
~/.herdr/workspaces/<repo-name>/<slugified-name>/
```

Keeping them out of the repo means no `.gitignore` entry per project and no risk
of an agent's tooling walking into a sibling workspace. Override the root with
`HERDR_JJ_ROOT`; override the agent command with `HERDR_JJ_AGENT`.

Base revision for a new workspace, first match wins:
`<name>@origin` → `<name>` → `main@origin` → `master@origin` → `trunk()` → `@`.
`herdr-jj` fetches first, so new work starts from what origin has now.

## The guard

`bin/agent-guard` runs on every `PreToolUse`. It distinguishes your checkout
from an agent's **structurally**, not by path:

- A repo's **main** workspace stores `.jj/repo` as the store *directory*.
- Every **secondary** (agent) workspace stores `.jj/repo` as a *file* pointing
  at that store.

So the guard keeps working wherever checkouts live, and can't be sidestepped by
moving one.

| Where | Behaviour |
|---|---|
| Main workspace | Passes through — your normal permissions, untouched |
| Agent workspace | `Write`/`Edit`/`MultiEdit`/`NotebookEdit` must target a path inside the workspace (symlinks and `../` resolved first) |
| Agent workspace | Outward-facing Bash commands get `ask`: push, `gh pr`/`gh issue` mutations, `gh api` writes, cloud/infra deletes, publishes, DB DDL, `jj workspace forget`, `jj op restore`, and `rm -r` outside the workspace |

**Known limit:** containment is enforced for the edit tools, but `Bash` is a
denylist, not a sandbox. `sed -i /etc/hosts` would still get through. Treat it
as a guardrail against an agent wandering off, not a security boundary.

Debug with `tail -f /tmp/agent-guard.log` (override via `AGENT_GUARD_LOG`).

## Agent skills

Skills live once in `agents/skills/` and are linked into every agent, so they're
tracked in this repo and not tied to one vendor:

```
agents/skills/            ← canonical, version-controlled
  ├── herdr/SKILL.md      ← official skill from herdrdev/herdr
  └── skills-lock.json    ← source + content hash, for updates
~/.agents/skills  → agents/skills   (pi, opencode, codex, … read this natively)
~/.claude/skills  → agents/skills   (Claude Code needs its own path)
```

Both symlinks are created by `install.sh`.

**`herdr`** — the official skill, teaching an agent to drive herdr from inside a
pane: split panes, start helper agents in siblings, read their output, wait on
lifecycle states. It refuses to act unless `HERDR_ENV=1`, so it can't touch a
session from outside. Note this is *sibling* delegation, orthogonal to the
one-agent-per-jj-workspace isolation above — both can be used together.

Add or update skills from the repo root:

```bash
cd agents && npx skills add <owner>/<repo> --skill <name> --agent universal -y
cd agents && npx skills update          # refresh vendored skills
```

Install with `--agent universal`: it writes the plain `skills/<name>/SKILL.md`
that every agent reads, instead of per-vendor copies. The `.agents/` nesting it
creates is flattened into `agents/skills/` by hand.

Scripted dispatch is still available (`herdr-jj new --repo … --prompt …`, which
uses `herdr agent start` to wait for readiness rather than sleeping), but there
is no longer a `/dispatch` skill — the herdr skill covers delegation.

## Tool Installation

**Prefer mise for all CLI tools.** Only use Homebrew for bootstrap dependencies
(mise itself, system-level packages that don't work well under mise). Everything
else — language runtimes, linters, CLI agents, formatters — goes in
`config/mise/config.toml`. This keeps tools version-pinnable, portable across
machines, and avoids Homebrew's "upgrade everything" behaviour.

## Notes

- **Portable across macOS and Linux.** Both scripts avoid GNU-only behaviour:
  no `readlink -f` (symlink chains are walked with POSIX `readlink`), no
  `sed -E` groups, no `timeout`, no bash 4+ features. Verified running under
  bash 3.2 (macOS system bash) as well as bash 5, and with `find` as a fallback
  when `fd` is absent — both discovery paths return identical results.
- **Agent state needs no setup.** herdr detects Claude Code and its
  working/idle/blocked state from its screen manifest. `herdr integration
  install claude` is optional and only adds session-resume identity.
- `bin/jj-workflow` (`jj pr`, `jj sync`, `jj start`) is otherwise unrelated to the
  agent system, but it is non-interactive-safe: it exports `JJ_EDITOR=true` and
  `GH_PROMPT_DISABLED=1` so it can never hang waiting on an editor or a prompt,
  and `--help` short-circuits before any fetch/rebase/push. Agent sessions get the
  same two variables from `claude/settings.json`.
- Old `<repo>/.jj-workspaces/` checkouts from the tmux system are not migrated;
  finish or `jj workspace forget` them. The `gitignore` entry stays harmlessly.

## Important

This file (AGENTS.md) is the canonical documentation for the agent system.
Other files that reference it (like CLAUDE.md) should symlink here rather than
duplicate content. Do not edit derivative files — edit this file instead.
