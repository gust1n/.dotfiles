---
name: planner-role
description: "Planner agent role in the planner/worker/judge loop. Bootstrap and coordinate from the planner pane: grill requirements → write plan → assign phases to worker → trigger judge review → close loop."
---

# Agent Loop

A planner starts solo — an ordinary `herdr-jj new` session — and grows a team
on demand: it spins up a worker, and later a judge, once a phase is concrete
enough to delegate, using `herdr-jj spawn` (see "Spinning up a worker or
judge" below). There is no dedicated terminal pane; run build/verify
commands yourself, or have the worker run them.

Loop order: `planner grills → planner plans → spin up worker → worker builds → spin up judge → judge reviews → (fix loop, max 3 rounds) → planner closes`

**Ownership split.** The planner owns the process: the plan files, phase
sequencing, ledger bookkeeping, and every jj history command (`new`,
`describe`, `commit`, `squash`, `split`, `abandon`). Worker and judge are
read-only with respect to jj history, and only ever need one file each —
their current phase file, described below. Keeping their scope narrow is what
keeps them from compacting mid-phase; see "Context discipline" for the
planner's own half of this.

This split assumes the planner carries the largest context budget in the
loop. Confirm that assumption instead of trusting the role names, because it
can flip:

| Harness | Model (this loop's default) | Window | Auto-compact |
|---|---|---|---|
| claude (planner) | `eu.anthropic.claude-opus-5[1m]` via Bedrock | ~1M tokens — the `[1m]` suffix on the model string is required; without it Bedrock's default Opus window is ~200K (confirmed: a real planner session hit auto-compact at ~165K cumulative input tokens before this fix landed) | yes, silent — see "Waiting for a worker" below |
| claude (worker/judge) | `eu.anthropic.claude-sonnet-5` via Bedrock | ~200K tokens — Claude Code's own `/model` picker only ever labels Opus "(1M context)", never Sonnet; the `[1m]` suffix is silently accepted for Sonnet too but an actually-widened window is unconfirmed, so don't rely on it | yes, silent |
| agy (any role) | `gemini-3.7-flash-medium` | ~1,048,576 tokens (1M), self-reported by the model | **none** — no user-facing compact command exists; if it fills, it fills |
| pi (any role) | whatever `--model` resolves to | pi's `provider/id` model syntax has no `[1m]`-equivalent flag; don't assume the loop's Bedrock 1M fix carries over | depends on provider |

If the worker or judge pane is running agy (or anything with a bigger window
than the planner's), the "planner has the room" assumption inverts for that
loop: the planner becomes the tighter constraint, not the worker. Re-derive
from this table, don't assume the row that matched last time still applies.

**Context reset per harness**, once a pane's own window fills (this is a
manual lever you reach for when polling shows a pane repeatedly compacting or
stalling, not a step you take proactively every phase):

| Harness | How to reset |
|---|---|
| claude | `/compact` then `/clear` if you want a clean slate; otherwise its own auto-compact handles it silently — don't trust it as a signal, see "Waiting for a worker" below |
| agy | `/clear` only — there is no user-triggered compact. Keep agy's phases short by design rather than relying on a reset that doesn't exist. |
| pi | `/new` |
| cursor | restart the agent |

**Before assuming any harness supports a flag** (model suffix, session name,
system-prompt file, whatever) — check that harness's own `--help` first.
Don't extrapolate from what claude or pi accepts to what agy accepts, or vice
versa; they diverge in ways that fail at launch time, not gracefully (seen in
practice: agy's `-i` argument encoding, and `ctrl+d` doing nothing to exit
its TUI when `/exit` was required).

Before anything, verify you are inside herdr:

```bash
test "${HERDR_ENV:-}" = 1 && echo ok || echo "not in herdr — stop"
```

### Agent identities

herdr resolves `agent prompt <name>` / `agent wait <name>` globally, not scoped
to this workspace — a bare `worker`/`judge` collides with any other planner
session running elsewhere on the machine and cross-talk gets misrouted
between them (seen in practice). Compute a namespace once, the first time you
read this skill in a session, and reuse it for every spawn:

```bash
NS=$(basename "$PWD")
PLANNER_AGENT="${NS}-planner"
WORKER_AGENT="${NS}-worker"
JUDGE_AGENT="${NS}-judge"

# Register yourself under this name too, even though nothing spawned you.
# `herdr-jj new` (the normal way to start a solo planner) never registers a
# namespaced name on its own — confirmed by hand: a plain session's pane has
# no `name` at all, only the auto-detected kind. Without this, a worker/judge
# you spawn later has no way to reach you back; do this before spawning
# anything, not after.
herdr agent rename "$HERDR_PANE_ID" "$PLANNER_AGENT" 2>/dev/null || true
```

Use `$WORKER_AGENT` / `$JUDGE_AGENT` in every `herdr agent` command below —
never the bare words `worker`/`judge`. You mint these names yourself now
(there is no launch script pre-assigning them); pass them as `<name>` to
`herdr-jj spawn`, described next.

Registration can drift back to a different name after launch even when
`herdr-jj spawn` reports success (rare — it defends against this once at spawn
time already). If a later `herdr agent prompt "$WORKER_AGENT"` /
`"$JUDGE_AGENT"` call fails with `agent_not_found`, check `herdr agent list`
for the pane under a different name and `herdr agent rename <pane_id>
"$WORKER_AGENT"` to re-assert it. Don't poll for this defensively every
round — it costs tokens for a rare failure; only check it when a signal
actually fails.

---

## Spinning up a worker or judge

Don't spawn speculatively. Spawn once a phase is concrete: you have a proof
command and a phase file ready (worker), or a diff ready to review (judge).
This mirrors how you'd decide to delegate at all — add an agent when the
unit genuinely needs one, not by default.

**Pick a kind and model.** A plain model name you or the user names resolves
to a `--kind`:

| You/user said | `--kind` | Model to pass |
|---|---|---|
| opus, sonnet, fable, haiku (default if unspecified: sonnet — cheap, narrow-scope work) | `claude` | the matching Bedrock id, e.g. `eu.anthropic.claude-sonnet-5` (or `[1m]`-suffixed only if this pane itself will hold outsized state — rare for a worker/judge, see the context-window table above) |
| gemini, flash, gemini flash | `flash` (an alias `herdr-jj spawn` translates to `agy` — omit `--model` and it defaults to `gemini-3.7-flash-medium`) | omit, or a specific gemini id to override the default |
| deepseek, or unspecified fast-coding | `pi` | whatever this repo's `pi` defaults resolve to; pass `--model` explicitly, `herdr-jj spawn` has no default for `pi` |

Judge default stays `claude`/sonnet unless told otherwise — agy is fine for
worker throughput but is not vetted here for unsupervised review judgment.

**Spawn:**

```bash
herdr-jj spawn "$WORKER_AGENT" --kind flash --from-pane "$HERDR_PANE_ID"
```

Use `--kind agy --model <id>` instead of `--kind flash` only if you need a
specific Gemini model other than the default.

`--from-pane "$HERDR_PANE_ID"` splits a fresh pane off your own — always use
your own pane as the source, never try to spawn *into* it directly (`agent
start` reports `agent_pane_busy` for a pane you're currently running the
command from, confirmed by hand). `herdr-jj spawn` handles the retry on a
freshly-split pane not yet settled, the defensive rename-verify, and a clear
error instead of a confusing one if the name is already taken. Read its own
`--help` rather than assuming these flags; it can change.

**Then brief it yourself, as a plain follow-up prompt — not baked into the
spawn command:**

```bash
herdr agent prompt "$WORKER_AGENT" \
  "You are the worker. Your herdr identity is $WORKER_AGENT; the planner is $PLANNER_AGENT. Read $PHASE_PATH. Load /worker-role and implement the work as directed. Signal $PLANNER_AGENT when done."
```

This two-step split (launch clean, then prompt) exists because baking a long
brief into `agent start`'s own arguments has failed outright for some kinds
(agy's argv encoding rejected it) but a plain `agent prompt` afterward has
worked reliably for every kind tried. Read back the pane after a few seconds
(`herdr agent read <pane> --lines 20`) to confirm the brief actually landed
rather than trusting the JSON response alone — delivery has silently
no-op'd once even though the call reported success.

Same pattern for the judge, once there's a diff:

```bash
herdr-jj spawn "$JUDGE_AGENT" --kind claude --from-pane "$HERDR_PANE_ID"
herdr agent prompt "$JUDGE_AGENT" \
  "You are the judge. Your herdr identity is $JUDGE_AGENT; the planner is $PLANNER_AGENT. Read $PHASE_PATH. Load /judge-role and review cold."
```

Spawn each only once per loop; reuse the same pane/name for later phases
rather than spawning a fresh worker every phase (that's what `/clear` or a
harness restart between phases is for — see the context-reset table above).

---

## Plan directory

One directory per task, not one file — this keeps every agent's per-round
read small and bounded regardless of how long the loop runs.

```
$MAIN_REPO/.plans/<task-slug>-<YYYY-MM-DD>/
  index.md            # status, current phase pointer, phase list, Open Questions
  plan.md              # Requirements, Acceptance Criteria, Architecture — written once
  phases/
    phase-1.md          # that phase's spec + Handoff Log + Review Ledger, self-contained
    phase-2.md
    ...
```

Gitignored, survives workspace deletion, same as before — only the shape
changed.

```bash
if [[ -f "$PWD/.jj/repo" ]]; then
  MAIN_REPO=$(cd "$PWD/.jj/$(cat $PWD/.jj/repo)/../.." && pwd -P)
else
  MAIN_REPO=$(jj workspace root 2>/dev/null || pwd)
fi
PLANS_DIR="$MAIN_REPO/.plans"
PLAN_DIR="$PLANS_DIR/<task-slug>-<YYYY-MM-DD>"
INDEX_PATH="$PLAN_DIR/index.md"
PLAN_PATH="$PLAN_DIR/plan.md"
mkdir -p "$PLAN_DIR/phases"
```

**Why the split matters:** `plan.md` is read once by the worker per phase at
most, and the judge normally never needs it — a phase file that copies down
whatever acceptance criteria apply to it is self-contained. `index.md` is the
only file re-read every round by the planner, and it stays small by
construction: it holds pointers and status, never findings or narration.
Nothing in `phases/` from a closed phase gets reopened during the loop; that
is the archival mechanism — there is no separate archive step or file.

### `index.md` template

```markdown
# Plan Index: <task>

Status: eliciting
Current phase: -

## Phases
(filled in as phases are created)
1. [Phase 1: <name>](phases/phase-1.md) — pending

## Open Questions
(escalations land here; each entry: question, who raised it, resolution)
```

### `plan.md` template

```markdown
# Plan: <task>
Date: <today>

## Requirements
## Acceptance Criteria
(each criterion: exact command + expected output or pass/fail signal)

## Architecture
```

### `phases/phase-N.md` template

```markdown
# Phase N: <name>

Scope: <what modules/files/methods are in scope>
Not scope: <explicit exclusions>
Worker decides: <implementation details within conventions>
Escalate to planner: <conditions that need a design decision>
Proof: <exact command>
Gate-blind risks: <what this phase can break that the proof command cannot detect>
Mutation check: <a guard/condition in this phase's code to deliberately break,
  confirm a *named* test fails, then restore — required whenever the phase
  adds or changes a guard/validation>
Done when: proof passes AND build gate passes AND mutation check passes

## Handoff Log
(worker writes here on completion)

## Review Ledger
| round | opened | closed | reopened | must-fix left | verdict |
|-------|--------|--------|----------|---------------|---------|

(judge writes findings here under `### Round <N>`, each with a stable ID
`P<N>-R<round>-<seq>`, e.g. `P3-R1-B1` — see judge-role for the format. Stable
IDs make reopened-finding and flip-flop detection a grep, not a re-read of
the whole ledger.)
```

Copy down into each phase file whatever slice of `## Acceptance Criteria`
from `plan.md` actually applies to that phase, when you write the phase
spec. That is what makes the phase file self-contained for worker and judge.

---

## Context discipline (planner)

You hold the biggest context budget in the loop and the longest-lived one —
protect it, or you compact too and lose the same state everyone else does.

- **Re-derive state from files, don't accumulate it in your own head.** At
  the top of each round, read `index.md` and the current phase file; trust
  what's on disk over what you remember from three rounds ago.
- **Never re-read a closed phase file** unless the human explicitly asks you
  to look back. Stop rules 2 and 3 only need the *current* phase's ledger.
- **Never re-read `plan.md`** after the phase files are written, unless
  writing a new phase spec that needs a fresh slice of it.
- **Anchor every read.** `Read $PHASE_PATH '## Review Ledger' / '### Round 2'`,
  never a bare `Read $PHASE_PATH`. This bounds what lands in your context per
  lookup, not just what's on disk.
- **Don't paste large output into your own reasoning.** A diff stat, a test
  summary line, a stable finding ID — reference it, don't quote it in full
  back to yourself.
- **Don't poll registration/identity state defensively.** Check it only when
  a signal actually fails (see "Agent identities" above).
- If you notice your own context is filling up mid-loop, checkpoint
  immediately: write current status to `index.md`, then continue. A stale
  `index.md` after your own compaction is exactly the failure mode this
  structure exists to prevent.

---

## Subject hygiene (task assignment)

When signalling the worker, use a **specific task subject** — not a phase number. The subject should name the exact component and include the proof command.

Bad: `"Phase 2 ready."`
Good: `"Implement the CreateUser handler in api/users. Proof: mise run test -- -v -run TestCreateUser ./api/users/..."`

Specific subjects make loops traceable and the proof command unambiguous.

---

## Oracle escalation (from worker)

The worker can signal you when blocked on a design or strategic decision. When this happens:

1. Read `## Open Questions` in `index.md`
2. Make the decision yourself if it is clear from requirements
3. Or ask the user if it requires product direction
4. Write the decision to the current phase file's spec section (or `plan.md`
   `## Architecture` if it's a cross-phase decision)
5. Signal worker to continue:

```bash
herdr agent prompt "$WORKER_AGENT" \
  "Decision made. Read $PHASE_PATH. Continue phase."
```

> "Loops without trusted verification compound slop." — joelclaw

Before assigning any phase to the worker, Planner must have a machine-verifiable proof path for that phase. Not "implement OAuth" — "implement OAuth: `mise run test -- ./foundation/auth/...` passes AND `pnpm test lib/auth` passes."

If you cannot write the proof command, write it as an Open Question in
`index.md` and resolve it with the user first.

---

## Mode A — Bootstrap: grill first (`/planner-role <task>`, from planner)

### 1. Grill the requirements

Before writing a plan, ask clarifying questions — **one at a time**. Goals:
- Understand the problem, not just the solution
- Get machine-verifiable acceptance criteria for every requirement
- Identify riskiest assumption and smallest acceptable version
- Find what's explicitly out of scope

Ask about the **riskiest assumption first** — the one that, if wrong, invalidates the entire approach. When answers are clear, create the plan directory and write `## Requirements` and `## Acceptance Criteria` to `plan.md`.

### 2. Plan phases, don't spawn yet

Write `## Phases` as a short outline in `plan.md` (names and one-line scope
only — the detailed phase spec with proof/gate-blind-risks/mutation-check
waits until you actually assign one, in Mode B). There is no worker or judge
to discover or signal at this point; you spawn each the first time you
actually need it ("Spinning up a worker or judge" above), not upfront.

---

## Waiting for a worker

Do not trust a worker's own "done" signal as your only source of truth —
compaction silently erases a session's memory of "signal the planner when
done," and the worker itself won't know it forgot (seen in practice: a
compacted worker just stopped signalling, with no error). Poll for
stable-idle instead of only listening for a signal:

```bash
herdr agent wait "$WORKER_AGENT" --timeout 1200000

# `agent_status` flickers mid-turn — confirm idle holds across a few checks,
# not just one, before trusting it:
for i in 1 2 3; do
  herdr agent get "$WORKER_AGENT" | python3 -c "
import json,sys; print(json.load(sys.stdin)['result']['agent']['agent_status'])
"
  sleep 5
done
```

- Three consecutive `idle` → read the phase file's `## Handoff Log`, whether
  or not the worker ever sent an explicit signal.
- `blocked` → check with `herdr agent read "$WORKER_AGENT" --source recent-unwrapped --lines 50`
- Still working after the long timeout → check in, don't just re-extend the timeout blindly.

---

## Mode B — Assign a phase to worker

```bash
PHASE_PATH="$PLAN_DIR/phases/phase-<N>.md"
```

Create it from the template above (including `Gate-blind risks` and
`Mutation check` — do not skip these, they're what the retro that motivated
this structure was written to fix). Add the phase to `index.md`'s list and
set `Current phase:`.

**If `$WORKER_AGENT` doesn't exist yet** (first phase, or a prior worker was
cleared/restarted), spawn it now — see "Spinning up a worker or judge"
above. Otherwise reuse the live one.

Then signal:

```bash
herdr agent prompt "$WORKER_AGENT" \
  "Phase <N>: <one-sentence description>. Read $PHASE_PATH. Signal done when proof passes."
herdr agent wait "$WORKER_AGENT" --timeout 1200000
```

---

## Mode C — Trigger judge review

**Pre-review yourself first.** Before triggering the judge, skim the diff for
anything in the phase file's `Gate-blind risks` line — those are exactly the
defects a green build gate cannot catch, and catching one yourself saves a
full judge round (seen in practice: this is how a real frontend gap got
caught in one loop instead of costing a round).

**If `$JUDGE_AGENT` doesn't exist yet**, spawn it now — see "Spinning up a
worker or judge" above. Otherwise reuse the live one.

```bash
herdr agent prompt "$JUDGE_AGENT" \
  "Review ready. Diff: $(cd $MAIN_REPO && jj diff --stat 2>/dev/null || git diff HEAD~1 --stat). Read $PHASE_PATH. Load /judge-role. Review cold — read the diff, not the worker's notes."
herdr agent wait "$JUDGE_AGENT" --timeout 600000
```

---

## Mode D — Fix loop (when judge blocks)

Judge writes BLOCK findings to the phase file's `## Review Ledger`, each with
a stable ID. Before relaying, grep that section for prior rounds' IDs — if a
new BLOCK reopens an ID that was previously closed, or contradicts a verdict
the judge itself gave last round, that is stop rule 2 or 3: stop, do not
relay to worker, hand to the human. Otherwise, relay:

```bash
herdr agent prompt "$WORKER_AGENT" \
  "Judge blocked. Read $PHASE_PATH '## Review Ledger' round <N>. Fix BLOCK items only. Signal done when build gate passes."
herdr agent wait "$WORKER_AGENT" --timeout 1200000
# Then re-trigger judge (Mode C)
```

**Stop rules** (judge applies these, planner enforces):
1. **Clean round** — no BLOCK findings → done, continue to next phase
2. **Reopened finding** — a finding ID from round N reappears in round N+1 → stop, hand to human
3. **Flip-flop** — judge asks to undo something it previously required (judge) → stop, hand to human
4. **Round cap hit** (3 rounds) → stop, hand to human with ledger summary

**Rebase onto `main@origin` at every phase boundary**, not only at the end.
A rebase deferred to `jj pr` time can surface a collision (e.g. two branches
claiming the same migration number) against dozens of accumulated upstream
commits at once, which is far more expensive to untangle than catching it one
phase at a time.

---

## Mode E — Worker signals done

Worker writes to the phase file's `## Handoff Log` and sends a herdr prompt.
Treat this the same as a stable-idle poll result (see "Waiting for a
worker") — read the handoff log and trigger judge review (Mode C) either
way, don't wait on the signal exclusively.

---

## Backpropagation (after loop completes)

Update the relevant `AGENTS.md` if a new gold standard pattern was established. Whether to record the decision elsewhere (e.g. an ADR) is the human's call, not the loop's.

---

## Loop states

```
eliciting → planning → in-progress → reviewing → complete
                           ↑____________↓ (judge blocks, max 3 rounds)
                                              ↑ human intervention if stop rules fire
```

Planner updates `Status:` and `Current phase:` in `index.md` at each transition.

---

## Rediscovering agents after restart

```bash
herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
  | python3 -c "
import json,sys
for p in json.load(sys.stdin)['result']['panes']:
    print(p.get('name','?'), p['pane_id'], p.get('agent_status',''))
"
# Find current status
cat "$MAIN_REPO/.plans/"*/index.md | grep -E '^Status:|^Current phase:'
```

---

## Protocol constraints

- **Short signals, rich plan files.** Never send large content via `herdr agent prompt` — send a path and an anchor.
- **Anchor every reference.** A signal names a specific file and heading, never a bare directory.
- **Spawn on demand, not speculatively.** No worker/judge until there's a concrete phase or diff for it; see "Spinning up a worker or judge."
- **Proof path required.** No phase without a machine-verifiable acceptance criterion.
- **Gate-blind risks and mutation check required.** No phase spec without both fields filled in.
- **Judge reviews cold.** Send diff stat, not the worker's handoff notes.
- **Stop rules are mandatory.** Don't override them to ship faster.
- **jj history is the planner's alone.** Worker and judge are read-only with respect to it.
- **Backpropagate learnings.** Update AGENTS.md when patterns are established.
- **Only planner emits `Status: complete`.**
