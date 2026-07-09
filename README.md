# mattstack

Personal Claude Code skills for Matt Goodwin.

## Skills

### orchestration

- **shepherdr** -- shepherd a herd of Claude Code agents via herdr panes. Breaks work into jobs, spawns an agent per job, monitors progress, sends follow-ups, and reports status. Requires the [herdr skill](https://github.com/ogulcancelik/herdr/blob/master/SKILL.md) (auto-installed if missing).

### infra

- **mattstack:run-feedback** -- analyze a run against the training plan with per-mile split breakdown, effort classification, and trend context. Generates data-dense feedback stored in the training app.

### workflow

- **matts-writing-style** -- voice, concision, and formatting rules for MR descriptions, MR comments, commit messages, and technical writing posted under Matt's name.

## Setup

Symlink each skill directory into `~/.claude/skills/`:

```bash
ln -s ~/Documents/GitHub/mattstack/skills/orchestration/shepherdr ~/.claude/skills/shepherdr
ln -s ~/Documents/GitHub/mattstack/skills/workflow/matts-writing-style ~/.claude/skills/matts-writing-style
ln -s ~/Documents/GitHub/mattstack/skills/infra/run-feedback ~/.claude/skills/mattstack:run-feedback
```
