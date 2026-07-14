# mattstack

Personal Claude Code skills for Matt Goodwin. All skills are scoped under the `mattstack:` prefix.

## Skills

### orchestration

- **mattstack:shepherdr** -- shepherd a herd of Claude Code agents via herdr panes. Breaks work into jobs, spawns an agent per job, monitors progress, sends follow-ups, and reports status. Requires the [herdr skill](https://github.com/ogulcancelik/herdr/blob/master/SKILL.md) (auto-installed if missing).

### infra

- **mattstack:local-app** -- set up a local web app as a persistent macOS service with HTTPS via portless and launchd. Handles port selection, plist creation, portless routing, and health checks.
- **mattstack:run-feedback** -- analyze a run against the training plan with per-mile split breakdown, effort classification, and trend context. Generates data-dense feedback stored in the training app.

### workflow

- **mattstack:matts-writing-style** -- voice, concision, and formatting rules for MR descriptions, MR comments, commit messages, and technical writing posted under Matt's name.

## Setup

Symlink each skill directory into `~/.claude/skills/`:

```bash
ln -s ~/Documents/GitHub/mattstack/skills/orchestration/shepherdr ~/.claude/skills/mattstack:shepherdr
ln -s ~/Documents/GitHub/mattstack/skills/workflow/matts-writing-style ~/.claude/skills/mattstack:matts-writing-style
ln -s ~/Documents/GitHub/mattstack/skills/infra/local-app ~/.claude/skills/mattstack:local-app
ln -s ~/Documents/GitHub/mattstack/skills/infra/run-feedback ~/.claude/skills/mattstack:run-feedback
```
