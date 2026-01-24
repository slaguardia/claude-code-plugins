#!/usr/bin/env bash
#
# validate-plugins.sh - Validate Claude Code plugin marketplace schema
#
# Usage: ./scripts/validate-plugins.sh
#
# Checks:
# - Plugin manifest (plugin.json) structure and required fields
# - No forbidden fields ($schema, scripts, dependencies in plugin.json)
# - YAML frontmatter in commands, skills, and agents
# - Version consistency between marketplace.json and plugin.json
# - Marketplace manifest structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

error() {
    echo -e "${RED}ERROR:${NC} $1"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo -e "${YELLOW}WARN:${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

info() {
    echo -e "${BLUE}→${NC} $1"
}

header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if jq is available
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}ERROR: jq is required but not installed.${NC}"
        echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
        exit 1
    fi
}

# Validate JSON file
validate_json() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        error "$file is not valid JSON"
        return 1
    fi
    return 0
}

# Check if file has YAML frontmatter
has_frontmatter() {
    local file="$1"
    head -1 "$file" 2>/dev/null | grep -q "^---$"
}

# Extract frontmatter field value
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    # Extract content between first --- and second ---
    sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | head -1
}

# Validate marketplace.json
validate_marketplace() {
    header "Validating marketplace.json"

    local marketplace_file="$ROOT_DIR/.claude-plugin/marketplace.json"

    if [[ ! -f "$marketplace_file" ]]; then
        error "marketplace.json not found at $marketplace_file"
        return 1
    fi

    if ! validate_json "$marketplace_file"; then
        return 1
    fi

    # Check required fields
    local name=$(jq -r '.name // empty' "$marketplace_file")
    local version=$(jq -r '.version // empty' "$marketplace_file")
    local description=$(jq -r '.description // empty' "$marketplace_file")
    local owner_name=$(jq -r '.owner.name // empty' "$marketplace_file")

    [[ -z "$name" ]] && error "marketplace.json missing 'name' field"
    [[ -z "$version" ]] && error "marketplace.json missing 'version' field"
    [[ -z "$description" ]] && error "marketplace.json missing 'description' field"
    [[ -z "$owner_name" ]] && error "marketplace.json missing 'owner.name' field"

    # Check plugins array exists
    local plugins_count=$(jq '.plugins | length' "$marketplace_file")
    if [[ "$plugins_count" -eq 0 ]]; then
        warn "marketplace.json has no plugins defined"
    else
        success "marketplace.json has $plugins_count plugins defined"
    fi

    success "marketplace.json structure is valid"
}

# Validate individual plugin.json
validate_plugin_json() {
    local plugin_dir="$1"
    local plugin_name=$(basename "$plugin_dir")
    local plugin_file="$plugin_dir/.claude-plugin/plugin.json"

    info "Checking $plugin_name"

    if [[ ! -f "$plugin_file" ]]; then
        error "$plugin_name: missing .claude-plugin/plugin.json"
        return 1
    fi

    if ! validate_json "$plugin_file"; then
        return 1
    fi

    # Check required fields
    local name=$(jq -r '.name // empty' "$plugin_file")
    local version=$(jq -r '.version // empty' "$plugin_file")
    local description=$(jq -r '.description // empty' "$plugin_file")
    local author_name=$(jq -r '.author.name // empty' "$plugin_file")

    [[ -z "$name" ]] && error "$plugin_name: missing 'name' field"
    [[ -z "$version" ]] && error "$plugin_name: missing 'version' field"
    [[ -z "$description" ]] && error "$plugin_name: missing 'description' field"

    # Check author is object with name (not string)
    local author_type=$(jq -r '.author | type' "$plugin_file")
    if [[ "$author_type" == "string" ]]; then
        error "$plugin_name: 'author' must be an object with 'name' property, not a string"
    elif [[ -z "$author_name" ]]; then
        error "$plugin_name: missing 'author.name' field"
    fi

    # Check for forbidden fields
    if jq -e '.["$schema"]' "$plugin_file" &>/dev/null; then
        error "$plugin_name: plugin.json should not have '\$schema' field (only marketplace.json uses it)"
    fi

    if jq -e '.scripts' "$plugin_file" &>/dev/null; then
        error "$plugin_name: plugin.json should not have 'scripts' field (scripts are auto-discovered)"
    fi

    if jq -e '.dependencies' "$plugin_file" &>/dev/null; then
        error "$plugin_name: plugin.json should not have 'dependencies' field"
    fi

    # Check for old 'tags' field (should be 'keywords')
    if jq -e '.tags' "$plugin_file" &>/dev/null; then
        error "$plugin_name: use 'keywords' instead of 'tags'"
    fi

    # Check for nested 'components' structure (old format)
    if jq -e '.components' "$plugin_file" &>/dev/null; then
        error "$plugin_name: 'components' should not be nested - use top-level 'skills', 'commands', 'agents'"
    fi

    success "$plugin_name: plugin.json valid"
}

# Validate version consistency
validate_version_consistency() {
    header "Validating version consistency"

    local marketplace_file="$ROOT_DIR/.claude-plugin/marketplace.json"

    # Get all plugins from marketplace
    local plugins=$(jq -r '.plugins[] | "\(.name):\(.version)"' "$marketplace_file")

    while IFS=: read -r name version; do
        local plugin_dir="$ROOT_DIR/plugins/$name"
        local plugin_file="$plugin_dir/.claude-plugin/plugin.json"

        if [[ -f "$plugin_file" ]]; then
            local plugin_version=$(jq -r '.version' "$plugin_file")
            if [[ "$version" != "$plugin_version" ]]; then
                error "$name: version mismatch - marketplace.json says $version, plugin.json says $plugin_version"
            else
                success "$name: version $version matches"
            fi
        fi
    done <<< "$plugins"
}

# Validate markdown files have frontmatter
validate_frontmatter() {
    local file="$1"
    local type="$2"  # command, skill, or agent
    local relative_path="${file#$ROOT_DIR/}"

    if ! has_frontmatter "$file"; then
        error "$relative_path: missing YAML frontmatter (must start with ---)"
        return 1
    fi

    case "$type" in
        command)
            if ! get_frontmatter_field "$file" "description" | grep -q "description:"; then
                error "$relative_path: missing 'description' in frontmatter"
            fi
            ;;
        skill)
            if ! get_frontmatter_field "$file" "name" | grep -q "name:"; then
                error "$relative_path: missing 'name' in frontmatter"
            fi
            if ! get_frontmatter_field "$file" "description" | grep -q "description:"; then
                error "$relative_path: missing 'description' in frontmatter"
            fi
            ;;
        agent)
            if ! get_frontmatter_field "$file" "name" | grep -q "name:"; then
                error "$relative_path: missing 'name' in frontmatter"
            fi
            if ! get_frontmatter_field "$file" "description" | grep -q "description:"; then
                error "$relative_path: missing 'description' in frontmatter"
            fi
            ;;
    esac
}

# Validate all commands in a plugin
validate_commands() {
    local plugin_dir="$1"
    local plugin_name=$(basename "$plugin_dir")
    local commands_dir="$plugin_dir/commands"

    if [[ ! -d "$commands_dir" ]]; then
        return 0
    fi

    local count=0
    for cmd_file in "$commands_dir"/*.md; do
        [[ -f "$cmd_file" ]] || continue
        validate_frontmatter "$cmd_file" "command"
        count=$((count + 1))
    done

    if [[ $count -gt 0 ]]; then
        success "$plugin_name: $count commands validated"
    fi
}

# Validate all skills in a plugin
validate_skills() {
    local plugin_dir="$1"
    local plugin_name=$(basename "$plugin_dir")
    local skills_dir="$plugin_dir/skills"

    if [[ ! -d "$skills_dir" ]]; then
        return 0
    fi

    local count=0
    for skill_dir in "$skills_dir"/*/; do
        [[ -d "$skill_dir" ]] || continue
        local skill_file="$skill_dir/SKILL.md"
        if [[ -f "$skill_file" ]]; then
            validate_frontmatter "$skill_file" "skill"
            count=$((count + 1))
        else
            warn "$plugin_name: skill directory $(basename "$skill_dir") missing SKILL.md"
        fi
    done

    if [[ $count -gt 0 ]]; then
        success "$plugin_name: $count skills validated"
    fi
}

# Validate all agents in a plugin
validate_agents() {
    local plugin_dir="$1"
    local plugin_name=$(basename "$plugin_dir")
    local agents_dir="$plugin_dir/agents"

    if [[ ! -d "$agents_dir" ]]; then
        return 0
    fi

    local count=0
    for agent_file in "$agents_dir"/*.md; do
        [[ -f "$agent_file" ]] || continue
        validate_frontmatter "$agent_file" "agent"
        count=$((count + 1))
    done

    if [[ $count -gt 0 ]]; then
        success "$plugin_name: $count agents validated"
    fi
}

# Main validation
main() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Claude Code Plugin Marketplace Validator             ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"

    check_dependencies

    # Validate marketplace.json
    validate_marketplace

    # Validate each plugin
    header "Validating plugin manifests"

    for plugin_dir in "$ROOT_DIR/plugins"/*/; do
        [[ -d "$plugin_dir" ]] || continue
        validate_plugin_json "$plugin_dir"
    done

    # Validate version consistency
    validate_version_consistency

    # Validate commands, skills, agents
    header "Validating commands, skills, and agents"

    for plugin_dir in "$ROOT_DIR/plugins"/*/; do
        [[ -d "$plugin_dir" ]] || continue
        validate_commands "$plugin_dir"
        validate_skills "$plugin_dir"
        validate_agents "$plugin_dir"
    done

    # Summary
    header "Validation Summary"

    if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}✓ All validations passed!${NC}"
        exit 0
    else
        [[ $ERRORS -gt 0 ]] && echo -e "${RED}✗ $ERRORS error(s) found${NC}"
        [[ $WARNINGS -gt 0 ]] && echo -e "${YELLOW}! $WARNINGS warning(s) found${NC}"
        exit $([[ $ERRORS -gt 0 ]] && echo 1 || echo 0)
    fi
}

main "$@"
