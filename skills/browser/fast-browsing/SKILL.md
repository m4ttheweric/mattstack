---
name: fast-browsing
description: Use when driving a browser through Playwright MCP tools for any multi-step task (form flows, navigation, clicking through UIs, scraping) and wall-clock speed or token cost matters
---

# Fast Browsing

## Overview

The browser is not the bottleneck; reading it is. A browser action takes 100-300ms, but every tool round trip costs a full inference pass over what it returns, and a full page snapshot is 10-60k characters. Speed = fewer round trips x smaller observations.

Benchmarked (5-step form flow, same model, same tools): step-at-a-time driving took 30-34 tool calls and 2-3.3 minutes; this loop took 7-8 calls and ~45 seconds, with identical task success.

## Before the loop: macros

Your FIRST tool call for any browser task is: Read `/Users/matt/.claude/skills/mattstack:browser-macros/MACROS.md`. An entry matches the task: your only browser action is ONE `browser_run_code_unsafe` call whose arguments are exactly that entry's `{ "filename": ..., "args": ... }` (the server loads the script from disk: never open the script file, no `code` argument), and you skip the loop. The macro fails twice: log it per the mattstack:browser-macros skill, then use the loop.

## The loop

1. **Scout once.** On an unfamiliar page, ONE `browser_snapshot` (or `browser_find` when you know what you're looking for) to learn the structure. Do not snapshot again unless genuinely lost.
2. **Act in one script, not clicks.** Write the ENTIRE known remaining flow as ONE `browser_run_code_unsafe` call: if you already know the inputs for five steps, that is one script, not five. Bake the waits in (`locator.waitFor()`, `page.waitForSelector`), and return only the distilled result you need: a value, a URL, a short list. Split into multiple scripts only where the next action depends on information you cannot get inside the same script.
3. **Read targeted.** To locate something: `browser_find` (text/regex, ~40x smaller than a snapshot). To read one region: `browser_snapshot` with `target`/`depth`. Full snapshot only when genuinely lost.
4. **Recover in step mode.** If a script throws twice on the same step, do that step with single-step tools, then resume batching.

## run_code rules

- Return distilled data (strings/small objects), never page dumps or element handles.
- try/catch each logical step; on failure return what succeeded plus the failing step's error and `page.url()`, so recovery is informed.
- Derive locators inside the script (`getByRole`, `getByLabel`, `getByText`); refs from earlier snapshots go stale after DOM changes.
- Poll/wait on conditions inside the script instead of returning to check and calling again.

## Anti-patterns

| Habit | Instead |
|---|---|
| Full snapshot after every action | Script asserts its own success; snapshot only to re-orient |
| One tool call per click/keystroke | Batch the whole form or flow into one script |
| Screenshot to "see" state | `browser_find` the text you expect |
| Returning to re-read the page after acting | Return a confirmation value from the same script |

## When NOT to apply

- Evidence capture (`assured:capture-evidence`): its documented step-by-step flow and deliberate screenshots take precedence; speed is not the goal there.
- Pages where each next action genuinely depends on unpredictable content: fall back to find-then-act per step, but still batch within each predictable stretch.
