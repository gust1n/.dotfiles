---
name: planner-role
description: "Planner agent role in the planner/worker/judge loop. Bootstrap and coordinate from the planner pane: grill requirements → write plan → assign phases to worker → trigger judge review → close loop."
---

# Agent Loop

A structured 3-agent cycle running inside one herdr workspace:

| Agent | Pane | Model | Role |
|-------|------|-------|------|
| **planner** | top-left | opus | grills requirements, plans, controls loop, human interface |
| **worker** | top-right | sonnet | implements, runs verification, escalates when blocked |
| **judge** | bottom-left | sonnet-5 | adversarial cold review, decides BLOCK or APPROVE |
| *(terminal)* | bottom-right | — | shell for builds, logs, manual verification |

Loop order: `planner grills → planner plans → worker builds → judge reviews → (fix loop, max 3 rounds) → planner closes`

Before anything, verify you are inside herdr:

```bash
test "${HERDR_ENV:-}" = 1 && echo ok || echo "not in herdr — stop"
```

---

## Subject hygiene (task assignment)

When signalling the worker, use a **specific task subject** — not a phase number. The subject should name the exact component and include the proof command.

Bad: `"Phase 2 ready."`
Good: `"Implement CreateDriver handler in backend/core/fleet/driversvc. Proof: cd backend && mise run test -- -v -run TestCreateDriver ./core/fleet/driversvc/..."`

Specific subjects make loops traceable and the proof command unambiguous.

---

## Oracle escalation (from worker)

The worker can signal you when blocked on a design or strategic decision. When this happens:

1. Read `## Open Questions` in the plan file
2. Make the decision yourself if it is clear from requirements
3. Or ask the user if it requires product direction
4. Write the decision to `## Architecture` or `## Phases` in the plan file
5. Signal worker to continue:

```bash
herdr agent prompt worker \
  "Decision made. Read $PLAN_PATH ## [section]. Continue phase." \
  --wait --timeout 60000
```

> "Loops without trusted verification compound slop." — joelclaw

Before assigning any phase to the worker, Planner must have a machine-verifiable proof path for that phase. Not "implement OAuth" — "implement OAuth: `mise run test -- ./foundation/auth/...` passes AND `pnpm test lib/auth` passes."

If you cannot write the proof command, write it as an Open Question and resolve it with the user first.

---

## Resolve main repo path

```bash
if [[ -f "$PWD/.jj/repo" ]]; then
  MAIN_REPO=$(cd "$PWD/.jj/$(cat $PWD/.jj/repo)/../.." && pwd -P)
else
  MAIN_REPO=$(jj workspace root 2>/dev/null || pwd)
fi
PLANS_DIR="$MAIN_REPO/.plans"
```

---

## Plan file

Lives in `$MAIN_REPO/.plans/<task-slug>-<YYYY-MM-DD>.md` (gitignored, survives workspace deletion).

```markdown
# Plan: <task>
Date: <today>
Status: eliciting

## Requirements
## Acceptance Criteria
(each criterion: exact command + expected output or pass/fail signal)

## Architecture
## Phases
## Handoff Log
## Open Questions
## Review Ledger
| round | opened | closed | reopened | must-fix left | verdict |
|-------|--------|--------|----------|---------------|---------|
```

---

## Mode A — Bootstrap: grill first (`/planner-role <task>`, from planner)

### 1. Grill the requirements

Before writing a plan, ask clarifying questions — **one at a time**. Goals:
- Understand the problem, not just the solution
- Get machine-verifiable acceptance criteria for every requirement
- Identify riskiest assumption and smallest acceptable version
- Find what's explicitly out of scope

Ask about the **riskiest assumption first** — the one that, if wrong, invalidates the entire approach. When answers are clear, write `## Requirements` and `## Acceptance Criteria` to the plan file.

### 2. Discover agents

```bash
herdr pane list --workspace "$HERDR_WORKSPACE_ID"
```

Agents are named `planner`, `worker`, `judge` (set by `herdr-jj new --layout loop`).

### 3. Signal workers with plan path + role

```bash
PLAN_PATH="$PLANS_DIR/<filename>"

herdr agent prompt worker \
  "Loop started. Plan: $PLAN_PATH. Load /worker-role. Wait for phase signal." \
  --wait --timeout 30000

herdr agent prompt judge \
  "Loop started. Plan: $PLAN_PATH. Load /judge-role. Wait for review signal." \
  --wait --timeout 30000
```

---

## Waiting for a worker

```bash
# Wait up to 20 min for worker (use herdr agent wait — never poll manually)
herdr agent wait worker --timeout 1200000

# Check how it settled
herdr agent get worker | python3 -c "
import json,sys; a=json.load(sys.stdin)['result']['agent']; print(a['agent_status'])
"
```

- `idle`/`done` → read handoff log in plan file
- `blocked` → check with `herdr agent read worker --source recent-unwrapped --lines 50`

---

## Mode B — Assign a phase to worker

Write the phase spec to `## Phases` using this format:

```markdown
## Phase N: <name>

Scope: <what modules/files/methods are in scope>
Not scope: <explicit exclusions>
Worker decides: <implementation details within conventions>
Escalate to planner: <conditions that need a design decision>
Proof: <exact command>
Done when: proof passes AND build gate passes
```

Then signal:

```bash
herdr agent prompt worker \
  "Phase <N>: <one-sentence description>. Plan: $PLAN_PATH ## Phases. Proof: <command>. Escalate if: <condition>. Signal done when proof passes." \
  --wait --timeout 60000
herdr agent wait worker --timeout 1200000
```

---

## Mode C — Trigger judge review

```bash
herdr agent prompt judge \
  "Review ready. Diff: $(cd $MAIN_REPO && git diff HEAD~1 --stat 2>/dev/null || jj diff --stat). Plan: $PLAN_PATH. Load /judge-role. Review cold — read the diff, not the worker's notes." \
  --wait --timeout 60000
herdr agent wait judge --timeout 600000
```

---

## Mode D — Fix loop (when judge blocks)

Judge writes BLOCK findings to `## Review Ledger`. Before relaying, scan the ledger for prior rounds — if a new BLOCK contradicts a previously APPROVED finding, that is a flip-flop: invoke stop rule 3 yourself, do not relay to worker. Otherwise, relay:

```bash
herdr agent prompt worker \
  "Judge blocked. Read $PLAN_PATH ## Review Ledger round <N>. Fix BLOCK items only. Signal done when build gate passes." \
  --wait --timeout 60000
herdr agent wait worker --timeout 1200000
# Then re-trigger judge (Mode C)
```

**Stop rules** (judge applies these, planner enforces):
1. **Clean round** — no BLOCK findings → done, continue to next phase
2. **Reopened finding** — a finding from round N reappears in round N+1 → stop, hand to human
3. **Flip-flop** — judge asks to undo something it previously required (judge) → stop, hand to human
4. **Round cap hit** (3 rounds) → stop, hand to human with ledger summary

---

## Mode E — Worker signals done

Worker writes to `## Handoff Log` in the plan file and sends a herdr prompt. When you receive it, read the handoff log and trigger judge review (Mode C).

---

## Backpropagation (after loop completes)

Before closing, write a structured lesson to `docs/lessons/` in the main repo. This is cross-session memory — future agents search it before debugging.

```bash
mkdir -p "$MAIN_REPO/docs/lessons"
LESSON="$MAIN_REPO/docs/lessons/$(date +%Y-%m-%d)-<task-slug>.md"
cat > "$LESSON" << 'EOF'
# Lesson: <task title>
Date: <today>
Domain: backend|frontend|infra|data

## Problem
<What we were trying to do and what was non-obvious>

## What we found
<Key decisions made, patterns established, gotchas discovered>

## Verify
<The command that proves this works>

## AGENTS.md changes
<If any AGENTS.md was updated, summarise what changed>
EOF
```

Also update the relevant `AGENTS.md` if a new gold standard pattern was established. File an ADR in `docs/adr/` if an architectural decision was made.

---

## Loop states

```
eliciting → planning → in-progress → reviewing → complete
                           ↑____________↓ (judge blocks, max 3 rounds)
                                              ↑ human intervention if stop rules fire
```

Planner updates `Status:` in the plan file at each transition.

---

## Rediscovering agents after restart

```bash
herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
  | python3 -c "
import json,sys
for p in json.load(sys.stdin)['result']['panes']:
    print(p.get('name','?'), p['pane_id'], p.get('agent_status',''))
"
# Find current status in plan file
cat "$MAIN_REPO/.plans/"*.md | grep '^Status:'
```

---

## Protocol constraints

- **Short signals, rich plan file.** Never send large content via `herdr agent prompt`.
- **Proof path required.** No phase without a machine-verifiable acceptance criterion.
- **Judge reviews cold.** Send diff stat, not the worker's handoff notes.
- **Stop rules are mandatory.** Don't override them to ship faster.
- **Backpropagate learnings.** Update AGENTS.md and ADRs when patterns are established.
- **Only planner emits `Status: complete`.**
