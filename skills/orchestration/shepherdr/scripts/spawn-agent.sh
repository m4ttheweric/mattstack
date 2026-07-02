#!/usr/bin/env bash
# Spawn one shepherdr agent: worktree + herdr tab + claude + kickoff prompt.
#
# Usage:
#   spawn-agent.sh -j <job-name> -b <branch> -J <path-to-job-brief.md> -w <workspace-id>
#                  [-r <repo-root>] [-k <kickoff-text>]
#
# Creates the worktree at ~/.shepherdr/worktrees/<repo>/<job-name>, copies the
# brief to <worktree>/.shepherdr/job.md, opens a --no-focus tab in the given
# workspace, launches claude, waits for readiness, sends the kickoff prompt.
# Prints the new pane id on stdout; everything else goes to stderr.
set -euo pipefail

usage() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

REPO_ROOT=""
KICKOFF=""
while getopts "j:b:J:w:r:k:" opt; do
  case "$opt" in
    j) JOB="$OPTARG" ;;
    b) BRANCH="$OPTARG" ;;
    J) JOB_MD="$OPTARG" ;;
    w) WORKSPACE="$OPTARG" ;;
    r) REPO_ROOT="$OPTARG" ;;
    k) KICKOFF="$OPTARG" ;;
    *) usage ;;
  esac
done
: "${JOB:?-j job-name required}" "${BRANCH:?-b branch required}"
: "${JOB_MD:?-J job brief path required}" "${WORKSPACE:?-w workspace id required}"
[ -n "$REPO_ROOT" ] || REPO_ROOT="$(git rev-parse --show-toplevel)"
[ -f "$JOB_MD" ] || { echo "job brief not found: $JOB_MD" >&2; exit 1; }

REPO_NAME="$(basename "$REPO_ROOT")"
WORKTREE="$HOME/.shepherdr/worktrees/$REPO_NAME/$JOB"
mkdir -p "$(dirname "$WORKTREE")"
git -C "$REPO_ROOT" worktree add "$WORKTREE" -b "$BRANCH" >&2

mkdir -p "$WORKTREE/.shepherdr"
cp "$JOB_MD" "$WORKTREE/.shepherdr/job.md"

PANE="$(herdr tab create --workspace "$WORKSPACE" --label "$JOB" --no-focus \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')"

herdr pane run "$PANE" "cd $WORKTREE"
herdr pane run "$PANE" "claude"

# Readiness: wait for herdr to detect the agent and see it idle. Matching
# --match ">" races the real prompt char and produces dead kickoff prompts.
if ! herdr wait agent-status "$PANE" --status idle --timeout 45000 >/dev/null 2>&1; then
  echo "spawn-agent: agent-status wait timed out for $PANE; falling back to prompt match" >&2
  herdr wait output "$PANE" --match "❯" --timeout 15000 >/dev/null
fi

if [ -z "$KICKOFF" ]; then
  KICKOFF="Read .shepherdr/job.md in the current directory and complete the entire job it describes. Work only inside this worktree and stay within the brief's scope fence. The brief's verification commands must pass. Whenever you need input from Matt, write .shepherdr/question.md in the multiple-choice format the brief shows, then stop and wait; the answer arrives as your next message. Even yes/no confirmations become numbered options. When the job is complete, write .shepherdr/report.md per the brief, then stop. Commit incrementally on this branch; never push; never commit the .shepherdr directory."
fi
herdr pane run "$PANE" "$KICKOFF"

echo "$PANE"
