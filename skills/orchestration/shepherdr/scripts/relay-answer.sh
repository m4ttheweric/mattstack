#!/usr/bin/env bash
# Relay an answer to an agent pane: clear any auto-drafted input, then send.
# Agents in auto mode often draft a suggested answer into their own input
# buffer; sending Enter would submit the draft, not your answer. Always
# ctrl+c first, then run.
#
# Usage: relay-answer.sh <pane-id> <answer text...>
set -euo pipefail
[ $# -ge 2 ] || { echo "usage: relay-answer.sh <pane-id> <answer text...>" >&2; exit 2; }
PANE="$1"; shift
herdr pane send-keys "$PANE" ctrl+c
sleep 1
herdr pane run "$PANE" "$*"
