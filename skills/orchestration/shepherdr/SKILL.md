---
name: shepherdr
description: "Shepherd a herd of Claude Code agents via herdr panes. Breaks work into jobs, spawns an agent per job in its own herdr pane, monitors progress via event-driven watchers, sends follow-up prompts, and reports status back. Use when the user wants to fan out work across multiple agents, delegate parallel tasks, or says 'shepherdr', 'shepherd', 'fan out', 'spawn agents', 'delegate this', 'split this across agents', 'herd this', or 'run these in parallel with herdr'."
---

# shepherdr

You are the shepherd. You do not do the hands-on work yourself. You break the work into jobs, send your herd of Claude Code agents out to do the work (each in its own herdr pane), and keep watch until everyone is done.

For herdr CLI mechanics (pane splitting, tab creation, workspace management, waiting, reading output), load the `herdr` skill. This skill covers orchestration -- what to spawn, how to monitor, and when to intervene.

## prerequisites

1. Confirm `HERDR_ENV=1` is set. If not, stop -- you need to be running inside herdr.
2. Check if the `herdr` skill is installed at `~/.claude/skills/herdr/SKILL.md`. If it exists, load it. If not, download and install it:
   ```bash
   mkdir -p ~/.claude/skills/herdr
   curl -fsSL https://raw.githubusercontent.com/ogulcancelik/herdr/master/SKILL.md -o ~/.claude/skills/herdr/SKILL.md
   ```
   Then load it. The herdr skill is required -- it has the CLI patterns for pane management, spawning agents, waiting, and reading output.
3. Run `herdr pane list` to find your own pane id and current layout.

## worktree isolation

Agents must NEVER work in the user's current checkout. Other agents (or the user) may be working there. Always create a git worktree so each agent has its own isolated working tree.

**Worktree location:** `~/.shepherdr/worktrees/<repo-name>/<job-name>/`

**Creating a worktree before spawning an agent:**

```bash
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
WORKTREE_DIR="$HOME/.shepherdr/worktrees/$REPO_NAME/<job-name>"
mkdir -p "$(dirname "$WORKTREE_DIR")"
git worktree add "$WORKTREE_DIR" -b <branch-name>
```

Then spawn the agent's pane with `--cwd "$WORKTREE_DIR"` (via workspace create or by running `cd` in the pane before launching claude).

**Cleanup after agents finish:**

```bash
git worktree remove "$WORKTREE_DIR"
# or if the agent left uncommitted changes:
git worktree remove --force "$WORKTREE_DIR"
```

Offer cleanup to the user during wrap-up (step 6). Don't auto-remove -- the user may want to inspect the worktree.

**When to skip worktree isolation:** only when the user explicitly says to work in the current checkout, or when the task is read-only (research, exploration, code review with no changes).

## step 1: assess complexity and choose workflow

Before breaking down work, decide whether this needs the full superpowers workflow or just direct prompts.

**Simple work** (isolated tasks, clear scope, no design decisions): write a good prompt per agent and spawn them. Skip to step 2.

**Complex work** (ambiguous scope, design decisions needed, multi-step features, cross-cutting changes): route the agent through the superpowers skill chain. The agent runs the skills in its own pane -- you monitor and relay.

**If unclear**, ask the user: "This could go either way -- should I use the superpowers workflow (brainstorm, spec, plan, implement with reviews) or just send direct prompts?"

### superpowers workflow

For complex work, the agent in the pane runs through superpowers sequentially:

1. `superpowers:brainstorming` -- explores requirements, produces a spec
2. The spec gets written to a file
3. `superpowers:writing-plans` -- produces an implementation plan from the spec
4. `superpowers:subagent-driven-development` or `superpowers:executing-plans` -- implements task by task with reviews at each step
5. `superpowers:finishing-a-development-branch` -- completion

**Your role during superpowers**: you are the quality gate between the agent and the user. The agent produces artifacts (specs, plans, etc.) and hits decision points. You handle both:

**Questions and decisions**: when the agent asks a non-trivial question, surface it to the user with structured questions (AskUserQuestion), then relay the answer back via `herdr pane run`. Trivial or obvious decisions (naming, file placement following existing patterns) -- answer on behalf of the user without interrupting them.

**Clearing auto-drafted input**: agents in auto mode often auto-draft a suggested answer into their input buffer after asking a question. Before relaying via `herdr pane run`, always clear the buffer first with `herdr pane send-keys <pane-id> ctrl+c`. Do NOT try `herdr pane send-keys <pane-id> Enter` to submit auto-drafted text -- it does not reliably go through. The safe pattern is always: `ctrl+c` to clear, then `pane run` with the full answer.

**Match the agent's expected input format**: when the agent asks a numbered-choice question ("Which approach? 1. Foo 2. Bar"), respond with just the number ("1"), not a paragraph restating the choice. When it asks a yes/no, respond "yes" or "no". When it asks for confirmation to proceed, respond "yes" or "go". Verbose responses can derail the agent's flow -- skills parse specific input formats and a wall of text can trigger interruptions or override the agent's intended next step. Keep relay messages minimal and shaped to what the agent is expecting.

**Artifact review gates**: when the agent completes a milestone artifact (spec, plan, etc.), do NOT immediately alert the user. First:

1. Read the artifact file yourself
2. Review it for obvious issues -- gaps, contradictions, missing requirements, scope creep, things that don't match what the user asked for
3. If you find issues, send the agent corrections via `herdr pane run` and let it revise. Repeat until clean.
4. Once satisfied, present the user with:
   - A concise summary of the artifact (key decisions, scope, approach)
   - Any issues you found and resolved during your review
   - A structured question asking for approval to proceed to the next phase

This means by the time the user sees anything, you've already done a first pass. The user reviews a clean artifact with your summary, not raw unvetted output.

## step 2: break down the work

Read the user's request and decompose into independent jobs. Each job becomes one agent in its own pane. For superpowers-routed work, each job is typically a whole feature or subsystem that runs through the full skill chain independently.

Good decomposition:
- Each job can run without waiting on another job's output
- Each job has a clear deliverable
- Jobs don't edit the same files (verify with `git status` before spawning if uncertain)

Sequential work (B needs A's output) runs one at a time -- use `herdr wait agent-status <pane> --status idle` to block until A finishes, then spawn B.

Cap at ~6 agents for a single batch. Beyond that, token cost from monitoring and context overhead outweighs the parallelism benefit.

## step 3: decide placement

Auto-decide based on context. Only ask the user if genuinely ambiguous.

- 1-2 agents, same repo: split panes in current tab
- 3+ agents, same repo: new tab per agent
- Agents in different repos: new workspace per repo
- User says "background": new workspace, no focus

## step 4: spawn the herd

For each job: create the worktree first (see worktree isolation above), then create a pane with `--no-focus` whose cwd is the worktree path. Launch claude and send the prompt. Use the herdr skill's `wait output --match ">" --timeout 15000` pattern to confirm claude is ready before sending the prompt.

```bash
# Example: create worktree, then spawn agent in it
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
WORKTREE="$HOME/.shepherdr/worktrees/$REPO_NAME/my-job"
git worktree add "$WORKTREE" -b feat/my-job
NEW_TAB=$(herdr tab create --workspace w18 --label "my-job" --no-focus | python3 -c 'import sys,json; r=json.load(sys.stdin)["result"]; print(r["root_pane"]["pane_id"])')
herdr pane run "$NEW_TAB" "cd $WORKTREE"
herdr pane run "$NEW_TAB" "claude"
herdr wait output "$NEW_TAB" --match ">" --timeout 15000
herdr pane run "$NEW_TAB" "the task prompt here"
```

Stagger launches for 4+ agents -- spawn one, confirm ready, spawn the next.

**Writing good prompts:** Each agent prompt should be self-contained -- goal in one sentence, specific files to touch, what "done" looks like, and constraints. Do not tell them to commit or push.

## step 5: watch the herd

Set up monitoring immediately after spawning. Two mechanisms, both set-and-forget:

**Completion watchers** -- for each agent, run `herdr wait agent-status <pane-id> --status idle --timeout 600000` via Bash with `run_in_background: true`. Fires a single notification when the agent finishes. Zero cost while waiting.

**Change-detection monitor** -- arm a single Monitor (`persistent: true`) that catches status transitions across all agents. Write the script to a scratchpad file to avoid quoting issues. The script polls `herdr pane list` every 30s, tracks previous status per pane, and emits a line only when a status changes (e.g., `working -> idle`, `working -> blocked`). This catches stuck or blocked agents that the completion watcher alone would miss.

### when a notification arrives

1. Read the pane: `herdr pane read <pane-id> --source recent --lines 50`
2. **Done**: summarize the result, check for issues, update status table
3. **Blocked/stuck**: read the output and decide:
   - Send a follow-up to unblock: `herdr pane run <pane-id> "<clarification>"`
   - If the agent can't recover, close the pane and tell the user what happened
   - Default: try one follow-up prompt before escalating
4. **Crashed/exited**: the pane will show a shell prompt instead of claude. Report to the user -- do not silently respawn.
5. **All done**: proceed to wrap-up

### mid-flight changes

If the user redirects scope while agents are running:
- Ask whether to let running agents finish or kill them
- To kill: `herdr pane close <pane-id>` for each affected agent
- Then respawn with updated prompts

### status table

When the user asks for status, or when reporting after a notification:

```
| job | pane | status | summary |
|-----|------|--------|---------|
| api tests | w18:p3 | done | 12 tests added, all passing |
| ui fix | w18:p4 | working | fixing dropdown alignment |
```

## step 6: wrap up

When all agents are done:

1. Read final output from each pane
2. Summarize what was accomplished
3. Flag conflicts (two agents touched the same file, failing tests, etc.)
4. Ask the user if they want to close the panes or keep them for review
5. Offer worktree cleanup -- list active worktrees under `~/.shepherdr/worktrees/` and ask which to remove (`git worktree remove <path>`). Don't auto-remove.
6. Do not commit on behalf of agents -- let the user decide

## rules

- `--no-focus` on every pane/tab/workspace creation
- Never guess pane ids -- re-read from `herdr pane list` if time has passed
- If an agent has no output for >2 minutes, read its pane and intervene
- Prioritize responding to the user over monitoring
- Keep status updates concise -- the user can look at panes directly
