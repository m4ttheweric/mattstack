---
name: browser-macros
description: Use when a browser task matches a known repeated flow - check MACROS.md for a pre-written macro script and run it via browser_run_code_unsafe filename+args instead of deriving the flow from scratch
---

# Browser Macros

Pre-written Playwright flow scripts for flows agents repeat often. Running a macro costs ~1 tool call and no code generation.

## Using a macro

1. Read `MACROS.md` in this skill directory. Match the task against each entry's description and target.
2. On a match, call `browser_run_code_unsafe` with `{ "filename": "<the entry's Script path>", "args": { ... } }` using the entry's params. Script paths are absolute under `/Users/matt/.playwright-mcp/macros/`; that location matters because the MCP server only reads files inside its output dir or cwd.
3. The macro returns a distilled result proving success, or `{ failedStep, error, url }` on failure.
4. If it fails twice or the entry does not match cleanly, fall back to the fast-browsing loop AND append one line to `~/.playwright-mcp/macro-failures.md`: `<macro-name> | <date> | <failedStep or reason>`.

## Macro script contract (for authors)

- Scripts live in `/Users/matt/.playwright-mcp/macros/` (an allowed read root for every MCP session); the index entry's Script field is the absolute path.
- Signature `async (page, args) => result`; merge defaults with `{ ...defaults, ...(args || {}) }` and return `{ failedStep: 'args', error: '<what is missing>' }` when a required arg is absent.
- Bake in waits (`waitForSelector`, `locator.waitFor`); never rely on the caller to wait.
- Return a small distilled value proving the flow completed.
- try/catch per logical step; on failure return `{ failedStep, error, url: page.url() }`.
