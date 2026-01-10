#!/bin/bash
#
# Ralph Wiggum Loop - Autonomous Claude Code execution
# Spawns fresh Claude instances until all Linear stories are complete
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MAX_ITERATIONS=10
SLEEP_BETWEEN=2

# Parse arguments
LINEAR_ISSUE_ID=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --sleep)
            SLEEP_BETWEEN="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: ralph.sh <LINEAR_ISSUE_ID> [options]"
            echo ""
            echo "Arguments:"
            echo "  LINEAR_ISSUE_ID    Parent Linear issue ID (e.g., PD-123)"
            echo ""
            echo "Options:"
            echo "  --max-iterations N  Maximum iterations before stopping (default: 10)"
            echo "  --sleep N           Seconds to wait between iterations (default: 2)"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  ralph.sh PD-123"
            echo "  ralph.sh PD-123 --max-iterations 20"
            exit 0
            ;;
        *)
            if [[ -z "$LINEAR_ISSUE_ID" ]]; then
                LINEAR_ISSUE_ID="$1"
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$LINEAR_ISSUE_ID" ]]; then
    echo -e "${RED}Error: Linear issue ID required${NC}"
    echo "Usage: ralph.sh <LINEAR_ISSUE_ID> [--max-iterations N]"
    exit 1
fi

# Check dependencies
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: claude CLI not found${NC}"
    echo "Install Claude Code CLI first"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq not found, some features may not work${NC}"
fi

# Block running on protected branches
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    echo -e "${RED}Error: Cannot run Ralph on protected branch '$CURRENT_BRANCH'${NC}"
    echo "Create a feature branch first: git checkout -b ralph/$LINEAR_ISSUE_ID"
    exit 1
fi

# State file
STATE_FILE=".ralph-state"

# Initialize or load state
init_state() {
    if [[ -f "$STATE_FILE" ]]; then
        CURRENT_ISSUE=$(jq -r '.linearIssueId // empty' "$STATE_FILE" 2>/dev/null || echo "")
        if [[ "$CURRENT_ISSUE" != "$LINEAR_ISSUE_ID" ]]; then
            echo -e "${YELLOW}Different issue detected. Archiving previous state...${NC}"
            archive_state
            create_state
        else
            ITERATION=$(jq -r '.iteration // 0' "$STATE_FILE")
            echo -e "${BLUE}Resuming from iteration $ITERATION${NC}"
        fi
    else
        create_state
    fi
}

create_state() {
    BRANCH_NAME="ralph/$(echo "$LINEAR_ISSUE_ID" | tr '[:upper:]' '[:lower:]')"
    ITERATION=0
    cat > "$STATE_FILE" << EOF
{
  "linearIssueId": "$LINEAR_ISSUE_ID",
  "branch": "$BRANCH_NAME",
  "iteration": 0,
  "startedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    echo -e "${GREEN}Created new Ralph state for $LINEAR_ISSUE_ID${NC}"
}

archive_state() {
    ARCHIVE_DIR=".ralph-archive"
    mkdir -p "$ARCHIVE_DIR"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    if [[ -f "$STATE_FILE" ]]; then
        mv "$STATE_FILE" "$ARCHIVE_DIR/state_$TIMESTAMP.json"
    fi
    if [[ -f "progress.txt" ]]; then
        cp "progress.txt" "$ARCHIVE_DIR/progress_$TIMESTAMP.txt"
    fi
    echo -e "${BLUE}Archived previous state to $ARCHIVE_DIR${NC}"
}

update_iteration() {
    local new_iteration=$1
    if [[ -f "$STATE_FILE" ]]; then
        jq ".iteration = $new_iteration" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
}

# Cleanup on completion
cleanup() {
    if [[ -f "$STATE_FILE" ]]; then
        rm "$STATE_FILE"
        echo -e "${BLUE}Cleaned up .ralph-state${NC}"
    fi
    if [[ -f "progress.txt" ]]; then
        rm "progress.txt"
        echo -e "${BLUE}Cleaned up progress.txt${NC}"
    fi
}

# Ensure progress.txt exists
ensure_progress_file() {
    if [[ ! -f "progress.txt" ]]; then
        cat > "progress.txt" << EOF
# Ralph Progress Log

## Feature: $LINEAR_ISSUE_ID
Started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

---

## Codebase Patterns

_Patterns discovered during implementation will be added here._

---

## Iteration Log

EOF
        echo -e "${GREEN}Created progress.txt${NC}"
    fi
}

# Main loop
run_loop() {
    init_state
    ensure_progress_file

    echo ""
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${BLUE}  Ralph Wiggum Loop - $LINEAR_ISSUE_ID${NC}"
    echo -e "${BLUE}  Max iterations: $MAX_ITERATIONS${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo ""

    for ((i=1; i<=MAX_ITERATIONS; i++)); do
        ITERATION=$((ITERATION + 1))
        update_iteration $ITERATION

        echo ""
        echo -e "${GREEN}-------------------------------------------------------${NC}"
        echo -e "${GREEN}  Iteration $ITERATION / $MAX_ITERATIONS${NC}"
        echo -e "${GREEN}  $(date)${NC}"
        echo -e "${GREEN}-------------------------------------------------------${NC}"
        echo ""

        # Create the prompt with the issue ID
        PROMPT=$(cat "$PLUGIN_DIR/skills/ralph/prompt.md" | sed "s/{{LINEAR_ISSUE_ID}}/$LINEAR_ISSUE_ID/g")

        # Run Claude with the prompt
        OUTPUT=$(echo "$PROMPT" | claude --dangerously-skip-permissions 2>&1) || true

        echo "$OUTPUT"

        # Check for completion signal
        if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
            cleanup
            echo ""
            echo -e "${GREEN}=======================================================${NC}"
            echo -e "${GREEN}  ALL STORIES COMPLETE!${NC}"
            echo -e "${GREEN}  Finished in $ITERATION iterations${NC}"
            echo -e "${GREEN}=======================================================${NC}"
            exit 0
        fi

        # Check for error signals
        if echo "$OUTPUT" | grep -q "BLOCKED\|ERROR\|needs breakdown"; then
            echo ""
            echo -e "${YELLOW}=======================================================${NC}"
            echo -e "${YELLOW}  Iteration encountered a blocker${NC}"
            echo -e "${YELLOW}  Check progress.txt for details${NC}"
            echo -e "${YELLOW}=======================================================${NC}"
            echo ""
            echo "Continue anyway? (y/N)"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi

        # Wait before next iteration
        if [[ $i -lt $MAX_ITERATIONS ]]; then
            echo ""
            echo -e "${BLUE}Waiting ${SLEEP_BETWEEN}s before next iteration...${NC}"
            sleep "$SLEEP_BETWEEN"
        fi
    done

    echo ""
    echo -e "${YELLOW}=======================================================${NC}"
    echo -e "${YELLOW}  Max iterations ($MAX_ITERATIONS) reached${NC}"
    echo -e "${YELLOW}  Check progress.txt for current status${NC}"
    echo -e "${YELLOW}=======================================================${NC}"
    exit 1
}

# Run it
run_loop
