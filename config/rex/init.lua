-- tmux-style bindings behind ctrl+a, mirroring config/tmux/tmux.conf.
-- Keys follow the Swedish layout and are matched without shift, so | is alt+7.

rex.bind("ctrl+a>a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>shift+r", "client.config.reload")

-- Tabs
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")
for i = 1, 9 do
  rex.bind("ctrl+a>" .. i, "client.tab.goto", { index = i })
end

-- Panes
rex.bind("ctrl+a>alt+7", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>tab", "pane.focus_next")
rex.bind("ctrl+a>shift+tab", "pane.focus_previous")
rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+a>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+a>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+a>l", "pane.focus", { direction = "right" })

-- Popups: a floating terminal over the current tab that closes when its command
-- exits. It starts in the directory of the focused pane's program, because
-- bash does not report its directory to Rex.
--
-- Rex draws a floating terminal's default background as transparent, and a
-- theme background doesn't change that. So the popup clears its screen with an
-- explicit background colour and gives fzf the same one.
--
-- Focusing the popup undoes a zoom, and closing it moves focus to another
-- pane. So when the command exits, the wrapper zooms or focuses the pane the
-- popup came from again, unless the command moved focus elsewhere.
local popup_wrap = [[
origin=$1 zoomed=$2; shift 2
printf '\033[48;2;38;38;38m\033[2J\033[H'
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --color=bg:#262626,preview-bg:#262626"
"$@"; rc=$?
win=$(rex block inspect -s "$REX_SESSION" "$REX_BLOCK" --json | jq -r .block.window_id)
here=$(rex window ls -s "$REX_SESSION" --json | jq -r --arg w "$win" \
  'select(.active_window_id == $w) | .windows[] | select(.window_id == $w) | .focused_block_id')
if [ "$here" = "$REX_BLOCK" ]; then
  if [ "$zoomed" = 1 ]; then rex zoom -s "$REX_SESSION" "$origin" --on; else rex focus -s "$REX_SESSION" "$origin"; fi >/dev/null 2>&1
fi
exit $rc]]
rex.action{
  name = "popup",
  title = "Run in Popup",
  args = { command = "array", w = "number?", h = "number?" },
  run = function(ctx, args)
    local terminal = "com.superlogical.terminal"
    local desc = rex.session.describe_block{ block_id = ctx.block_id }
    local proc = rex.block.call(terminal, "process", { block_id = ctx.block_id }) or {}
    local cwd = (proc.foreground and proc.foreground.cwd)
      or (proc.ancestors and proc.ancestors[1] and proc.ancestors[1].cwd) or ""
    local zoomed = "0"
    for _, win in ipairs((rex.session.view{} or {}).windows or {}) do
      if win.window_id == desc.block.window_id and win.zoomed_block_id == ctx.block_id then
        zoomed = "1"
      end
    end
    local w, h = args.w or 0.8, args.h or 0.7
    rex.session.new_layer{
      window_id = desc.block.window_id,
      bounds = { (1 - w) / 2, (1 - h) / 2, w, h },
      focus = true,
      layout = rex.layout.block{
        flavor = terminal .. ".shell",
        options = {
          command = { "sh", "-c", popup_wrap, "popup", ctx.block_id, zoomed,
            unpack(args.command) },
          cwd = cwd,
        },
      },
    }
  end,
}

-- Agents in jj workspaces (bin/rex-jj)
rex.bind("ctrl+a>s", "popup", { command = { "rex-jj", "agents" } })
rex.bind("ctrl+a>shift+a", "popup", { command = { "rex-jj", "new" } })
rex.bind("ctrl+a>shift+d", "popup", { command = { "rex-jj", "rm" }, w = 0.7, h = 0.4 })
rex.bind("ctrl+a>shift+y", "popup", { command = { "rex-jj", "tidy" }, w = 0.7, h = 0.5 })
