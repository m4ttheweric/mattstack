---
name: mine-macros
description: Use when asked to mine browser session logs for repeated flows and turn them into macros - sweeps ~/.playwright-mcp session logs, proposes parameterized macro scripts with evidence, and updates the browser-macros library only after per-macro approval
---

# Mine Macros

Turns repeated agent browser flows into approved macros for the browser-macros skill.

**The output of mining is proposals, never installs.** A macro enters the library only through explicit per-macro approval from the user in this conversation. Writing a script or index entry before approval, or marking any entry `Status: approved` yourself, is a violation, even if the macro is obviously good, even if it was verified live, even if the user seems busy.

## Procedure

1. **Repair queue first.** Read `~/.playwright-mcp/macro-failures.md` (if present). For each failed macro, find recent sessions touching the same origin, draft a fixed script, and queue it as a repair proposal.
2. **Collect.** Read every `~/.playwright-mcp/session-*/session.md` (skip `archive/` and `macros/`). Parse each into an ordered flow: tool name, key args (URLs, selectors, run_code bodies), one flow per session. Treat unparseable sessions as no-ops and report them.
3. **Cluster.** Group flows by origin plus action-sequence similarity. A candidate is a flow appearing in 2 or more sessions. Repeated hand-written run_code bodies targeting the same origin are the strongest candidates.
4. **Skip known rejects and coverage.** Drop candidates matching entries in `rejected.md` (this skill's directory) or flows already covered by `mattstack:browser-macros/MACROS.md`.
5. **Draft.** For each candidate write the macro script per the browser-macros script contract (`async (page, args) => result`, waits baked in, try/catch with `{ failedStep, error, url }`). Parameterize values that varied across the observed sessions; hardcode values that never varied. Draft in memory or a temp file, NOT in `~/.playwright-mcp/macros/`.
6. **Propose.** Present each candidate with AskUserQuestion: name, description, params, the script, and evidence (session folders, occurrence count). One question per candidate, options Approve / Reject / Edit first.
7. **Apply dispositions.** Approved: write `/Users/matt/.playwright-mcp/macros/<name>.js`, append the MACROS.md entry (absolute Script path, `Status: approved`, `Last verified:` today). Rejected: append one line to `rejected.md` (`<name> | <date> | <one-line reason>`). Repairs: overwrite the script, bump Last verified, remove the macro-failures.md line.
8. **Archive.** Move processed `session-*` folders to `~/.playwright-mcp/archive/`. Delete `archive/` members older than 30 days. NEVER touch `~/.playwright-mcp/macros/`. Report: candidates found, approved, rejected, repaired, sessions archived and pruned.

## Red flags - stop, you are about to violate the approval gate

- "This macro is clearly useful, I'll install it and mention it"
- "I verified it live, so approved status is accurate"
- "I'll write the file now and ask afterwards"

All of these mean: present the proposal and wait.

## Notes

- Do not propose macros for one-off flows or flows that only read data trivially reachable with browser_find.
- Macro-run sessions (a single filename call) are evidence a macro works, not candidates.
