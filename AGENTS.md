# Agent Management System

This dotfiles repo contains a tmux-based system for running parallel Claude Code agents in isolated jj workspaces.

**See [PERSONAL.md](PERSONAL.md) for general workflow instructions (version control, tools, code style).**

## Architecture

```
bin/agent          - Main orchestrator (interactive popup + CLI)
bin/agent-status   - Hook helper that sets tmux window status icons
bin/agent-check-stale - Detects agents stuck in "working" state
bashrc.d/100.agent.sh - Adds bin/ to PATH + tab completion
config/tmux/tmux.conf - Window status format, keybindings, stale check
~/.claude/settings.json - Hooks (UserPromptSubmit, Notification, PostToolUse, Stop)
~/.claude/skills/dispatch.md - Skill for dispatching agents from driver seat
```

## How it connects

1. `C-a A` opens `bin/agent` in a tmux popup
2. "New agent" flow: pick repo → name task → pick agent → creates jj workspace at `<repo>/.jj-workspaces/<name>/` → opens tmux window `ag:<name>`
3. Claude Code hooks in `~/.claude/settings.json` call `agent-status` on state changes
4. `agent-status` sets `@agent_status` tmux window option → rendered in status bar via `#{?@agent_status, #{@agent_status},}`
5. `agent-check-stale` runs every 15s (via tmux status-left) and flips stale agents to warning icon

## Keybindings

- `C-a A` — Interactive menu (switch windows, new agent, kill)
- `C-a l` — Jump to first agent that is done/waiting/stale

## Icons (Nerd Font, via printf escapes)

- `\xef\x80\x93` — working (cog)
- `\xef\x83\xa5` — waiting for input (comment)
- `\xef\x80\x8c` — done (check)
- `\xef\x81\xb1` — stale/interrupted (warning)

Icons auto-clear when you focus the agent's window.

## CLI usage

```bash
agent                  # Interactive menu
agent new              # Interactive: repo → task → agent → workspace
agent new --repo /path --name task-name --agent claude --prompt "..."  # Scripted
agent ls               # List agent windows with status
agent switch [name]    # Switch to agent window
agent kill [name]      # Kill + clean up jj workspace
agent send <name> msg  # Send input to agent
agent capture <name>   # Read agent's terminal output
agent jump-next        # Jump to done/waiting agent
```

## Dispatching from Claude Code (skill)

From the "driver seat" Claude instance, use `/dispatch` to spawn agents:
```
/dispatch fix the auth timeout bug in the middleware
```
This creates a workspace, opens a window, and passes the prompt to a new claude instance.

## Workspace lifecycle

- Created at `<repo>/.jj-workspaces/<name>/` (gitignored)
- Forked from: bookmark@origin > bookmark > main@origin > trunk() > @
- Cleaned up on `agent kill` or when agent exits and user presses Enter

## Extending

- To add new agent types: edit `_pick_agent()` in `bin/agent`
- To change icons: edit printf escapes in `bin/agent-status` and `bin/agent-check-stale`
- To change stale threshold: edit `STALE_THRESHOLD` in `bin/agent-check-stale` (default 30s)

## Important

This file (AGENTS.md) is the canonical documentation for the agent system.
Other files that reference it (like CLAUDE.md) should symlink here rather than duplicate content.
Do not edit derivative files — edit this file instead.
