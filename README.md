# mattstack

Personal Claude Code skills for Matt Goodwin.

## Skills

### orchestration

- **herdr** -- control herdr from inside it. manage workspaces, tabs, panes, spawn agents, read output, and wait for state changes via CLI commands over a local unix socket.
- **shepherdr** -- shepherd a herd of Claude Code agents via herdr panes. breaks work into jobs, spawns an agent per job, monitors progress, sends follow-ups, and reports status.

### workflow

- **matts-writing-style** -- voice, concision, and formatting rules for MR descriptions, MR comments, commit messages, and technical writing posted under Matt's name.

## Usage

Symlink each skill directory into `~/.claude/skills/`:

```bash
ln -s ~/Documents/GitHub/mattstack/skills/orchestration/herdr ~/.claude/skills/herdr
ln -s ~/Documents/GitHub/mattstack/skills/orchestration/shepherdr ~/.claude/skills/shepherdr
ln -s ~/Documents/GitHub/mattstack/skills/workflow/matts-writing-style ~/.claude/skills/matts-writing-style
```
