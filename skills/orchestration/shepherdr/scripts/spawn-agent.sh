#!/usr/bin/env bash
# Spawn one shepherdr agent: worktree + herdr tab + claude + kickoff prompt.
#
# Usage:
#   spawn-agent.sh -j <job-name> (-b <branch> | -d <existing-dir>) -J <brief.md>
#                  -w <workspace-id> [-r <repo-root>] [-k <kickoff-text>] [-m <model>]
#
# With -b: creates the worktree at ~/.shepherdr/worktrees/<repo>/<job-name>.
# With -d: uses the existing directory as-is (no git worktree add); any branch
# must already be provisioned there. -m launches claude with --model <model>.
# Copies the brief to the job dir ~/.shepherdr/jobs/<repo>/<job-name>/job.md
# (contract files never live inside the repo), opens a --no-focus tab in the
# given workspace, launches claude, waits for readiness, sends the kickoff.
# Prints the new pane id on stdout; everything else goes to stderr.
set -euo pipefail

usage() { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

REPO_ROOT=""
KICKOFF=""
BRANCH=""
DIR=""
MODEL=""
while getopts "j:b:J:w:r:k:d:m:" opt; do
  case "$opt" in
    j) JOB="$OPTARG" ;;
    b) BRANCH="$OPTARG" ;;
    J) JOB_MD="$OPTARG" ;;
    w) WORKSPACE="$OPTARG" ;;
    r) REPO_ROOT="$OPTARG" ;;
    k) KICKOFF="$OPTARG" ;;
    d) DIR="$OPTARG" ;;
    m) MODEL="$OPTARG" ;;
    *) usage ;;
  esac
done
: "${JOB:?-j job-name required}"
: "${JOB_MD:?-J job brief path required}" "${WORKSPACE:?-w workspace id required}"
if [ -n "$DIR" ] && [ -n "$BRANCH" ]; then echo "spawn-agent: -b and -d are mutually exclusive" >&2; exit 2; fi
if [ -z "$DIR" ] && [ -z "$BRANCH" ]; then echo "spawn-agent: one of -b <branch> or -d <existing-dir> is required" >&2; exit 2; fi
[ -f "$JOB_MD" ] || { echo "job brief not found: $JOB_MD" >&2; exit 1; }

if [ -n "$DIR" ]; then
  [ -d "$DIR" ] || { echo "directory not found: $DIR" >&2; exit 1; }
  WORKTREE="$DIR"
  REPO_NAME="$(basename "$DIR")"
else
  [ -n "$REPO_ROOT" ] || REPO_ROOT="$(git rev-parse --show-toplevel)"
  REPO_NAME="$(basename "$REPO_ROOT")"
  WORKTREE="$HOME/.shepherdr/worktrees/$REPO_NAME/$JOB"
  mkdir -p "$(dirname "$WORKTREE")"
  git -C "$REPO_ROOT" worktree add "$WORKTREE" -b "$BRANCH" >&2
fi

# Contract files live outside the repo: zero worktree footprint.
JOB_DIR="$HOME/.shepherdr/jobs/$REPO_NAME/$JOB"
mkdir -p "$JOB_DIR"
cp "$JOB_MD" "$JOB_DIR/job.md"
echo "spawn-agent: job dir $JOB_DIR" >&2

PANE="$(herdr tab create --workspace "$WORKSPACE" --label "$JOB" --no-focus \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')"

herdr pane run "$PANE" "cd $WORKTREE"
herdr pane run "$PANE" "claude${MODEL:+ --model '$MODEL'}"

# Readiness: wait for herdr to detect the agent and see it idle. Matching
# --match ">" races the real prompt char and produces dead kickoff prompts.
if ! herdr wait agent-status "$PANE" --status idle --timeout 45000 >/dev/null 2>&1; then
  echo "spawn-agent: agent-status wait timed out for $PANE; falling back to prompt match" >&2
  herdr wait output "$PANE" --match "❯" --timeout 15000 >/dev/null
fi

if [ -z "$KICKOFF" ]; then
  KICKOFF="Your job directory is $JOB_DIR -- it is outside the repo, and all job/question/report and scratch files belong there, NEVER in the repo or worktree. Read $JOB_DIR/job.md and complete the entire job it describes. Work only inside this worktree and stay within the brief's scope fence. The brief's verification commands must pass. Whenever you need input from Matt, write $JOB_DIR/question.md in the multiple-choice format the brief shows, then stop and wait; the answer arrives as your next message. Even yes/no confirmations become numbered options. When the job is complete, write $JOB_DIR/report.md per the brief, then stop. Commit incrementally on this branch; never push. The worktree must contain only the work itself."
fi
herdr pane run "$PANE" "$KICKOFF"

echo "$PANE"
