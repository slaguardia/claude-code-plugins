#!/usr/bin/env bash
#
# validate-frontmatter.sh - Check what `claude plugin validate` does not.
#
# The official validator owns manifest schema. It does NOT read SKILL.md or
# agent frontmatter: a SKILL.md with no frontmatter passes it and is silently
# dead at runtime. That gap is this script's whole job.
#
# Checks:
# - every skills/**/SKILL.md has `name` and `description`
# - `name` matches its directory
# - no two skills share a name (they collide inside one plugin)
# - every agents/*.md has `name` and `description`
# - every path listed in plugin.json exists on disk
#
# Usage: ./scripts/validate-frontmatter.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
ERRORS=0

error() { echo -e "${RED}ERROR:${NC} $1"; ERRORS=$((ERRORS + 1)); }

# Print the value of a frontmatter key, or nothing.
field() {
    awk -v key="$2" '
        NR == 1 && $0 != "---" { exit }
        NR > 1 && $0 == "---"  { exit }
        NR > 1 {
            if (match($0, "^" key ":[ \t]*")) {
                print substr($0, RLENGTH + 1)
                exit
            }
        }
    ' "$1"
}

echo "Validating skill frontmatter"

declare -a SEEN_NAMES=()
SKILL_COUNT=0

while IFS= read -r skill_md; do
    dir_name="$(basename "$(dirname "$skill_md")")"
    name="$(field "$skill_md" name)"
    desc="$(field "$skill_md" description)"

    if [ -z "$name" ]; then
        error "$skill_md: missing 'name' in frontmatter"
        continue
    fi
    if [ -z "$desc" ]; then
        error "$skill_md: missing 'description' in frontmatter"
    fi
    if [ "$name" != "$dir_name" ]; then
        error "$skill_md: name '$name' does not match directory '$dir_name'"
    fi
    for seen in ${SEEN_NAMES[@]+"${SEEN_NAMES[@]}"}; do
        if [ "$seen" = "$name" ]; then
            error "$skill_md: duplicate skill name '$name'"
        fi
    done
    SEEN_NAMES+=("$name")
    SKILL_COUNT=$((SKILL_COUNT + 1))
done < <(find skills -name SKILL.md | sort)

echo -e "${GREEN}✓${NC} $SKILL_COUNT skills checked"

echo "Validating agent frontmatter"
AGENT_COUNT=0
if [ -d agents ]; then
    while IFS= read -r agent_md; do
        [ -z "$(field "$agent_md" name)" ] && error "$agent_md: missing 'name' in frontmatter"
        [ -z "$(field "$agent_md" description)" ] && error "$agent_md: missing 'description' in frontmatter"
        AGENT_COUNT=$((AGENT_COUNT + 1))
    done < <(find agents -name '*.md' | sort)
fi
echo -e "${GREEN}✓${NC} $AGENT_COUNT agents checked"

echo "Validating manifest paths"
PATH_COUNT=0
while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    if [ ! -e "$entry" ]; then
        error "plugin.json lists $entry, which does not exist"
    fi
    PATH_COUNT=$((PATH_COUNT + 1))
done < <(jq -r '((.skills // []) + (.agents // []) + (.commands // []))[]' .claude-plugin/plugin.json)
echo -e "${GREEN}✓${NC} $PATH_COUNT manifest paths checked"

# Anything on disk but absent from the manifest ships nothing.
while IFS= read -r skill_md; do
    dir="./$(dirname "$skill_md")"
    if ! jq -e --arg d "$dir" '(.skills // []) | index($d)' .claude-plugin/plugin.json >/dev/null; then
        error "$dir exists but is not listed in plugin.json, so it will not ship"
    fi
done < <(find skills -name SKILL.md -not -path '*/in-progress/*' | sort)

echo
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}✗ $ERRORS error(s) found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ All checks passed${NC}"
