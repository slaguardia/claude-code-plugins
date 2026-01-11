#!/bin/bash
#
# Team Planning Loop - Two-Agent Adversarial Planning
# Planning Agent and Research Agent alternate until comprehensive plan is ready
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
MAX_ITERATIONS=7
SLEEP_BETWEEN=2
VERBOSE=false
TEAM_NAME=""
LINEAR_ISSUE_ID=""
FEATURE_TEXT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --issue)
            LINEAR_ISSUE_ID="$2"
            shift 2
            ;;
        --team)
            TEAM_NAME="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: team-loop.sh [options] \"feature description\""
            echo "       team-loop.sh --issue PD-123 [options]"
            echo ""
            echo "Arguments:"
            echo "  \"feature description\"  Plain text description of the feature"
            echo ""
            echo "Options:"
            echo "  --issue ID           Use existing Linear issue as input"
            echo "  --team NAME          Linear team name (auto-detected if not specified)"
            echo "  --max-iterations N   Maximum planning cycles (default: 7)"
            echo "  --verbose            Show full agent outputs"
            echo "  --help, -h           Show this help message"
            echo ""
            echo "Examples:"
            echo "  team-loop.sh \"hosts need to message event attendees\""
            echo "  team-loop.sh --issue PD-123"
            echo "  team-loop.sh --max-iterations 5 \"add dark mode toggle\""
            exit 0
            ;;
        *)
            if [[ -z "$FEATURE_TEXT" && ! "$1" =~ ^-- ]]; then
                FEATURE_TEXT="$1"
            fi
            shift
            ;;
    esac
done

# Validate input
if [[ -z "$LINEAR_ISSUE_ID" && -z "$FEATURE_TEXT" ]]; then
    echo -e "${RED}Error: Provide either a feature description or --issue ID${NC}"
    echo "Usage: team-loop.sh \"feature description\" or team-loop.sh --issue PD-123"
    exit 1
fi

# Check dependencies
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: claude CLI not found${NC}"
    echo "Install Claude Code CLI first"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required for JSON parsing${NC}"
    echo "Install jq: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

# State files
STATE_FILE=".team-state.json"
CONTEXT_FILE="planning-context.json"

# Initialize state
init_state() {
    local input_type="text"
    local input_value="$FEATURE_TEXT"

    if [[ -n "$LINEAR_ISSUE_ID" ]]; then
        input_type="linear"
        input_value="$LINEAR_ISSUE_ID"
        echo -e "${BLUE}Fetching Linear issue $LINEAR_ISSUE_ID...${NC}"
        # We'll fetch the issue content in the first planning iteration
    fi

    cat > "$STATE_FILE" << EOF
{
  "input": {
    "type": "$input_type",
    "value": "$input_value",
    "linearIssueId": $([ -n "$LINEAR_ISSUE_ID" ] && echo "\"$LINEAR_ISSUE_ID\"" || echo "null")
  },
  "iteration": 0,
  "maxIterations": $MAX_ITERATIONS,
  "startedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "status": "initializing"
}
EOF

    # Initialize context file
    cat > "$CONTEXT_FILE" << EOF
{
  "originalInput": $(echo "$input_value" | jq -Rs .),
  "inputType": "$input_type",
  "linearIssueId": $([ -n "$LINEAR_ISSUE_ID" ] && echo "\"$LINEAR_ISSUE_ID\"" || echo "null"),
  "currentPlan": null,
  "researchFindings": [],
  "feedbackHistory": []
}
EOF

    echo -e "${GREEN}Initialized planning state${NC}"
}

update_state() {
    local iteration=$1
    local status=$2
    jq ".iteration = $iteration | .status = \"$status\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# Build Planning Agent prompt
build_planning_prompt() {
    local context=$(cat "$CONTEXT_FILE")
    local prompt=$(cat "$PLUGIN_DIR/prompts/planning-agent.md")

    # Replace context placeholder
    echo "$prompt" | sed "s|{{CONTEXT}}|$context|g"
}

# Build Research Agent prompt
build_research_prompt() {
    local context=$(cat "$CONTEXT_FILE")
    local prompt=$(cat "$PLUGIN_DIR/prompts/research-agent.md")

    # Replace context placeholder
    echo "$prompt" | sed "s|{{CONTEXT}}|$context|g"
}

# Extract content between tags
extract_tag_content() {
    local output="$1"
    local tag="$2"
    echo "$output" | sed -n "/<$tag>/,/<\/$tag>/p" | sed "1d;\$d"
}

# Update context with planning output
update_context_with_plan() {
    local plan_json="$1"
    local iteration="$2"

    # Validate JSON before updating
    if ! echo "$plan_json" | jq . > /dev/null 2>&1; then
        echo -e "${YELLOW}Warning: Invalid JSON in plan output, attempting to extract...${NC}"
        return 1
    fi

    # Update context file with new plan
    jq --argjson plan "$plan_json" '.currentPlan = $plan' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
}

# Update context with research feedback
update_context_with_feedback() {
    local feedback_json="$1"
    local iteration="$2"

    # Validate JSON before updating
    if ! echo "$feedback_json" | jq . > /dev/null 2>&1; then
        echo -e "${YELLOW}Warning: Invalid JSON in feedback output${NC}"
        return 1
    fi

    # Add feedback to history
    jq --argjson feedback "$feedback_json" --argjson iter "$iteration" \
        '.feedbackHistory += [($feedback + {"iteration": $iter})]' \
        "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
}

# Run Planning Agent
run_planning_agent() {
    local iteration=$1

    echo -e "${CYAN}  [Planning Agent] Creating/refining user stories...${NC}"

    local prompt=$(build_planning_prompt)

    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}--- Planning Prompt ---${NC}"
        echo "$prompt" | head -50
        echo "..."
    fi

    local output=$(echo "$prompt" | claude --dangerously-skip-permissions 2>&1) || true

    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}--- Planning Output ---${NC}"
        echo "$output"
    fi

    # Extract plan JSON
    local plan_content=$(extract_tag_content "$output" "plan")

    if [[ -n "$plan_content" ]]; then
        if update_context_with_plan "$plan_content" "$iteration"; then
            echo -e "${GREEN}  [Planning Agent] Plan updated successfully${NC}"
            return 0
        fi
    fi

    echo -e "${RED}  [Planning Agent] Failed to extract valid plan${NC}"
    return 1
}

# Run Research Agent
run_research_agent() {
    local iteration=$1

    echo -e "${CYAN}  [Research Agent] Researching and validating plan...${NC}"

    local prompt=$(build_research_prompt)

    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}--- Research Prompt ---${NC}"
        echo "$prompt" | head -50
        echo "..."
    fi

    local output=$(echo "$prompt" | claude --dangerously-skip-permissions 2>&1) || true

    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}--- Research Output ---${NC}"
        echo "$output"
    fi

    # Check for DONE signal
    if echo "$output" | grep -q "<signal>DONE</signal>"; then
        echo -e "${GREEN}  [Research Agent] Plan approved! No gaps found.${NC}"

        # Extract research summary for final output
        local summary=$(extract_tag_content "$output" "research_summary")
        if [[ -n "$summary" ]]; then
            jq --arg summary "$summary" '.finalResearchSummary = $summary' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
        fi

        return 0  # DONE
    fi

    # Extract feedback
    local feedback_content=$(extract_tag_content "$output" "feedback")

    if [[ -n "$feedback_content" ]]; then
        if update_context_with_feedback "$feedback_content" "$iteration"; then
            local gap_count=$(echo "$feedback_content" | jq '.gaps | length' 2>/dev/null || echo "?")
            echo -e "${YELLOW}  [Research Agent] Found $gap_count gap(s) - sending back to Planning Agent${NC}"
            return 1  # CONTINUE
        fi
    fi

    echo -e "${YELLOW}  [Research Agent] No clear signal - assuming more work needed${NC}"
    return 1  # CONTINUE
}

# Create Linear issues from final plan
create_linear_issues() {
    echo ""
    echo -e "${BLUE}Creating Linear issues from final plan...${NC}"

    # Build the issue creation prompt
    local context=$(cat "$CONTEXT_FILE")
    local create_prompt="You have a finalized feature plan. Create Linear issues from it.

## Context
$context

## Instructions

1. First, list teams using mcp__linear-server__list_teams to find the team ID
2. Create a parent issue with:
   - Title: \"Feature: [summary from plan]\"
   - Description containing:
     - Summary
     - Out of Scope items
     - Technical Considerations
     - Research Summary (from finalResearchSummary)
3. For each user story in currentPlan.userStories, create a sub-issue with:
   - parentId set to the parent issue ID
   - Title: \"[id]: [title]\" (e.g., \"US-001: Story title\")
   - Description containing the user story and acceptance criteria

Use the mcp__linear-server__create_issue tool for each issue.

Output the created issue IDs when done."

    if [[ -n "$TEAM_NAME" ]]; then
        create_prompt="$create_prompt

Use team: $TEAM_NAME"
    fi

    local output=$(echo "$create_prompt" | claude --dangerously-skip-permissions 2>&1) || true

    echo "$output"
}

# Cleanup state files
cleanup() {
    if [[ -f "$STATE_FILE" ]]; then
        rm "$STATE_FILE"
    fi
    if [[ -f "$CONTEXT_FILE" ]]; then
        # Keep context file for reference
        mv "$CONTEXT_FILE" "planning-result-$(date +%Y%m%d_%H%M%S).json"
        echo -e "${BLUE}Saved final plan to planning-result-*.json${NC}"
    fi
}

# Main loop
run_loop() {
    init_state

    echo ""
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${BLUE}  Team Planning Loop${NC}"
    echo -e "${BLUE}  Max iterations: $MAX_ITERATIONS${NC}"
    if [[ -n "$LINEAR_ISSUE_ID" ]]; then
        echo -e "${BLUE}  Input: Linear issue $LINEAR_ISSUE_ID${NC}"
    else
        echo -e "${BLUE}  Input: \"$FEATURE_TEXT\"${NC}"
    fi
    echo -e "${BLUE}=======================================================${NC}"
    echo ""

    for ((i=1; i<=MAX_ITERATIONS; i++)); do
        update_state $i "planning"

        echo ""
        echo -e "${GREEN}-------------------------------------------------------${NC}"
        echo -e "${GREEN}  Iteration $i / $MAX_ITERATIONS${NC}"
        echo -e "${GREEN}  $(date)${NC}"
        echo -e "${GREEN}-------------------------------------------------------${NC}"
        echo ""

        # Run Planning Agent
        if ! run_planning_agent $i; then
            echo -e "${RED}Planning Agent failed - retrying once...${NC}"
            sleep 2
            if ! run_planning_agent $i; then
                echo -e "${RED}Planning Agent failed twice - exiting${NC}"
                exit 1
            fi
        fi

        update_state $i "researching"

        # Wait briefly between agents
        sleep 1

        # Run Research Agent
        if run_research_agent $i; then
            # DONE signal received
            echo ""
            echo -e "${GREEN}=======================================================${NC}"
            echo -e "${GREEN}  PLAN APPROVED!${NC}"
            echo -e "${GREEN}  Completed in $i iteration(s)${NC}"
            echo -e "${GREEN}=======================================================${NC}"
            echo ""

            # Create Linear issues
            create_linear_issues

            cleanup
            exit 0
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
    echo -e "${YELLOW}  Plan may not be fully refined${NC}"
    echo -e "${YELLOW}=======================================================${NC}"

    # Still create issues with current plan
    echo ""
    echo "Create Linear issues with current plan anyway? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        create_linear_issues
    fi

    cleanup
    exit 1
}

# Run it
run_loop
