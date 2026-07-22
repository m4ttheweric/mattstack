# Macro Index

## page-recon
- Description: navigate to a URL and return a compact reconnaissance of the page - final URL, title, an inventory of every input/select/textarea/button (tag, type, id, name, label, visibility, select options), and body text capped at textChars. Use on an unfamiliar page instead of hand-rolling goto + content dumps; leaves the page open for follow-up actions.
- Params: { url: string (required), textChars?: number (default 600) }
- Target: any page (site-agnostic)
- Script: /Users/matt/.playwright-mcp/macros/page-recon.js
- Last verified: 2026-07-21
- Status: approved

## order-wizard
- Description: complete the 5-step order wizard on the bench page (name, shipping, quantity, terms, submit) and return the confirmation code
- Params: { name?: string (default "Ada Lovelace"), quantity?: string (default "3"), shipping?: "standard"|"priority"|"overnight" (default "priority"), url?: string (default "http://127.0.0.1:8749/wizard.html") }
- Target: http://127.0.0.1:8749/wizard.html
- Script: /Users/matt/.playwright-mcp/macros/order-wizard.js
- Last verified: 2026-07-21
- Status: approved
