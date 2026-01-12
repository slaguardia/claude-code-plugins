#!/bin/bash
#
# Team Planning Loop - Two-Agent Adversarial Planning (Local Tasks)
# Planning Agent and Research Agent alternate until comprehensive plan is ready
# Saves tasks to local JSON files instead of Linear
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANNING_PROMPT="$SCRIPT_DIR/planning-agent.md"
RESEARCH_PROMPT="$SCRIPT_DIR/research-agent.md"

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
MARKDOWN_FILE=""
FEATURE_TEXT=""
TASKS_DIR=".tasks"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --file)
            MARKDOWN_FILE="$2"
            shift 2
            ;;
        --tasks-dir)
            TASKS_DIR="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: team-loop.sh [options] \"feature description\""
            echo "       team-loop.sh --file path/to/feature.md [options]"
            echo ""
            echo "Arguments:"
            echo "  \"feature description\"  Plain text description of the feature"
            echo ""
            echo "Options:"
            echo "  --file PATH          Import from markdown file"
            echo "  --tasks-dir DIR      Output directory for tasks (default: .tasks)"
            echo "  --max-iterations N   Maximum planning cycles (default: 7)"
            echo "  --verbose            Show full agent outputs"
            echo "  --help, -h           Show this help message"
            echo ""
            echo "Examples:"
            echo "  team-loop.sh \"hosts need to message event attendees\""
            echo "  team-loop.sh --file feature-spec.md"
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
if [[ -z "$MARKDOWN_FILE" && -z "$FEATURE_TEXT" ]]; then
    echo -e "${RED}Error: Provide either a feature description or --file PATH${NC}"
    echo "Usage: team-loop.sh \"feature description\" or team-loop.sh --file feature.md"
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

# Read markdown file if provided
if [[ -n "$MARKDOWN_FILE" ]]; then
    if [[ ! -f "$MARKDOWN_FILE" ]]; then
        echo -e "${RED}Error: File not found: $MARKDOWN_FILE${NC}"
        exit 1
    fi
    FEATURE_TEXT=$(cat "$MARKDOWN_FILE")
    echo -e "${BLUE}Loaded feature from: $MARKDOWN_FILE${NC}"
fi

# State files
STATE_FILE=".team-state.json"
CONTEXT_FILE="planning-context.json"

# Create tasks directory
mkdir -p "$TASKS_DIR"

# Initialize state
init_state() {
    local input_type="text"
    local input_value="$FEATURE_TEXT"

    if [[ -n "$MARKDOWN_FILE" ]]; then
        input_type="markdown"
        echo -e "${BLUE}Using markdown file: $MARKDOWN_FILE${NC}"
    fi

    cat > "$STATE_FILE" << EOF
{
  "input": {
    "type": "$input_type",
    "source": $([ -n "$MARKDOWN_FILE" ] && echo "\"$MARKDOWN_FILE\"" || echo "null")
  },
  "iteration": 0,
  "maxIterations": $MAX_ITERATIONS,
  "startedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "tasksDir": "$TASKS_DIR",
  "status": "initializing"
}
EOF

    # Initialize context file
    cat > "$CONTEXT_FILE" << EOF
{
  "originalInput": $(echo "$input_value" | jq -Rs .),
  "inputType": "$input_type",
  "sourceFile": $([ -n "$MARKDOWN_FILE" ] && echo "\"$MARKDOWN_FILE\"" || echo "null"),
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
    if [[ ! -f "$PLANNING_PROMPT" ]]; then
        echo -e "${RED}Error: planning-agent.md not found at $PLANNING_PROMPT${NC}" >&2
        echo "Make sure you copied all files: team-loop.sh, planning-agent.md, research-agent.md" >&2
        exit 1
    fi
    local context=$(cat "$CONTEXT_FILE")
    local prompt=$(cat "$PLANNING_PROMPT")

    # Replace context placeholder
    echo "$prompt" | sed "s|{{CONTEXT}}|$context|g"
}

# Build Research Agent prompt
build_research_prompt() {
    if [[ ! -f "$RESEARCH_PROMPT" ]]; then
        echo -e "${RED}Error: research-agent.md not found at $RESEARCH_PROMPT${NC}" >&2
        echo "Make sure you copied all files: team-loop.sh, planning-agent.md, research-agent.md" >&2
        exit 1
    fi
    local context=$(cat "$CONTEXT_FILE")
    local prompt=$(cat "$RESEARCH_PROMPT")

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

# Generate unique feature ID
generate_feature_id() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local random_suffix=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 4)
    echo "FEAT-${timestamp}-${random_suffix}"
}

# Save tasks to local JSON files
save_local_tasks() {
    echo ""
    echo -e "${BLUE}Saving tasks to local JSON files...${NC}"

    local context=$(cat "$CONTEXT_FILE")
    local feature_id=$(generate_feature_id)
    local feature_dir="$TASKS_DIR/$feature_id"

    mkdir -p "$feature_dir/stories"

    # Extract plan data
    local summary=$(echo "$context" | jq -r '.currentPlan.summary // "No summary"')
    local out_of_scope=$(echo "$context" | jq '.currentPlan.outOfScope // []')
    local tech_considerations=$(echo "$context" | jq '.currentPlan.technicalConsiderations // []')
    local research_summary=$(echo "$context" | jq -r '.finalResearchSummary // ""')

    # Create feature.json (parent task)
    cat > "$feature_dir/feature.json" << EOF
{
  "id": "$feature_id",
  "title": "Feature: $summary",
  "summary": $(echo "$summary" | jq -Rs .),
  "status": "planning",
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "outOfScope": $out_of_scope,
  "technicalConsiderations": $tech_considerations,
  "researchSummary": $(echo "$research_summary" | jq -Rs .),
  "storiesCount": 0
}
EOF

    # Create individual story JSON files
    local story_count=0
    local stories=$(echo "$context" | jq -c '.currentPlan.userStories // []')

    echo "$stories" | jq -c '.[]' | while read -r story; do
        story_count=$((story_count + 1))
        local story_id=$(echo "$story" | jq -r '.id')
        local story_title=$(echo "$story" | jq -r '.title')
        local user_story=$(echo "$story" | jq -r '.userStory')
        local acceptance_criteria=$(echo "$story" | jq '.acceptanceCriteria')
        local dependencies=$(echo "$story" | jq '.dependencies // []')

        cat > "$feature_dir/stories/${story_id}.json" << EOF
{
  "id": "$story_id",
  "featureId": "$feature_id",
  "title": $(echo "$story_title" | jq -Rs .),
  "userStory": $(echo "$user_story" | jq -Rs .),
  "acceptanceCriteria": $acceptance_criteria,
  "dependencies": $dependencies,
  "status": "todo",
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "completedAt": null,
  "iteration": null
}
EOF
        echo -e "${GREEN}  Created: stories/${story_id}.json${NC}"
    done

    # Update story count in feature.json
    local actual_count=$(ls -1 "$feature_dir/stories/"*.json 2>/dev/null | wc -l | tr -d ' ')
    jq --argjson count "$actual_count" '.storiesCount = $count' "$feature_dir/feature.json" > "$feature_dir/feature.json.tmp" && mv "$feature_dir/feature.json.tmp" "$feature_dir/feature.json"

    # Create index.json for easy listing
    cat > "$feature_dir/index.json" << EOF
{
  "featureId": "$feature_id",
  "featureFile": "feature.json",
  "storiesDir": "stories/",
  "totalStories": $actual_count,
  "completedStories": 0,
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    echo ""
    echo -e "${GREEN}Tasks saved to: $feature_dir${NC}"
    echo -e "${BLUE}  feature.json - Main feature definition${NC}"
    echo -e "${BLUE}  stories/     - Individual user story files${NC}"
    echo -e "${BLUE}  index.json   - Quick reference index${NC}"
    echo ""
    echo -e "${CYAN}To start implementation:${NC}"
    echo -e "  /ralph $feature_id"
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
    echo -e "${BLUE}  Team Planning Loop (Local Tasks)${NC}"
    echo -e "${BLUE}  Max iterations: $MAX_ITERATIONS${NC}"
    if [[ -n "$MARKDOWN_FILE" ]]; then
        echo -e "${BLUE}  Input: Markdown file $MARKDOWN_FILE${NC}"
    else
        echo -e "${BLUE}  Input: \"${FEATURE_TEXT:0:60}...\"${NC}"
    fi
    echo -e "${BLUE}  Output: $TASKS_DIR/${NC}"
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

            # Save to local JSON files
            save_local_tasks

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

    # Still save tasks with current plan
    echo ""
    echo "Save tasks with current plan anyway? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        save_local_tasks
    fi

    cleanup
    exit 1
}

# Run it
run_loop
