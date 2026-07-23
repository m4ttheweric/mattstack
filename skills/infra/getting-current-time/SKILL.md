---
name: mattstack:getting-current-time
description: Use whenever the current time matters ... answering "what time is it", timestamping output, scheduling, computing relative dates ("yesterday", "in 2 hours"), or reasoning about timezones. The context window only carries the date, never the time of day, so the clock must be read from the machine.
---

# Getting Current Time

## Overview

Read the clock from the machine; never estimate the time from the knowledge cutoff or the context date. The context date has no time of day and may be stale within a long session.

## How

Run the script in this skill's base directory:

```bash
bash <base-dir>/get-time.sh
```

Output:

```
Local: 2026-07-23 13:30:05 CDT (UTC-0500)
Zone:  America/Chicago
UTC:   2026-07-23 18:30:05
```

Use the `Zone:` line (IANA name) for anything DST-sensitive; the abbreviation (CDT) is ambiguous.

## Common Mistakes

- Answering with only a date because that is all the context provides. Run the script.
- Doing timezone math from a remembered offset. DST shifts offsets; the script prints the live one.
- Reusing a time read earlier in a long session. Re-run the script; time moved on.
