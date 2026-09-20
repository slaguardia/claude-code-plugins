#!/usr/bin/env bash
#
# link-skills.sh - Symlink this repo's skills into ~/.claude/skills/
#
# Use this instead of installing the marketplace locally. A plugin install is a
# read-only managed copy, so edits made there are lost on the next update.
# Symlinks point at the working tree, so editing a skill here takes effect
# immediately and shows up in `git status`.
#
# Usage:
#   ./scripts/link-skills.sh           # create or refresh the symlinks
#   ./scripts/link-skills.sh --dry-run # show what would change
#   ./scripts/link-skills.sh --unlink  # remove symlinks this script created

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

DRY_RUN=false
UNLINK=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --unlink)  UNLINK=true ;;
        -h|--help) sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'; exit 0 ;;
        *) echo "unknown option: $arg" >&2; exit 1 ;;
    esac
done

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'

run() {
    if [ "$DRY_RUN" = true ]; then
        echo "  would run: $*"
    else
        "$@"
    fi
}

mkdir -p "$TARGET_DIR"

LINKED=0
UNCHANGED=0
CONFLICTS=0
REMOVED=0

while IFS= read -r skill_md; do
    skill_dir="$(dirname "$skill_md")"
    name="$(basename "$skill_dir")"
    link="$TARGET_DIR/$name"

    if [ "$UNLINK" = true ]; then
        # Only remove links that point back into this repo.
        if [ -L "$link" ] && [[ "$(readlink "$link")" == "$ROOT_DIR"/* ]]; then
            run rm "$link"
            echo -e "${YELLOW}removed${NC} $name"
            REMOVED=$((REMOVED + 1))
        fi
        continue
    fi

    if [ -L "$link" ]; then
        if [ "$(readlink "$link")" = "$skill_dir" ]; then
            UNCHANGED=$((UNCHANGED + 1))
            continue
        fi
        run rm "$link"
    elif [ -e "$link" ]; then
        echo -e "${RED}conflict${NC} $name: $link already exists as a real directory."
        echo "         Delete it to link this repo's copy, or keep yours and drop it from the repo."
        CONFLICTS=$((CONFLICTS + 1))
        continue
    fi

    run ln -s "$skill_dir" "$link"
    echo -e "${GREEN}linked${NC} $name -> ${skill_dir#$ROOT_DIR/}"
    LINKED=$((LINKED + 1))
done < <(find "$ROOT_DIR/plugins" -name SKILL.md -not -path '*/node_modules/*' | sort)

echo
if [ "$UNLINK" = true ]; then
    echo "removed $REMOVED symlink(s) from $TARGET_DIR"
else
    echo "linked $LINKED, unchanged $UNCHANGED, conflicts $CONFLICTS, into $TARGET_DIR"
    echo "Edit a skill under plugins/ and the change is live in your next session."
    if [ "$CONFLICTS" -gt 0 ]; then
        echo
        echo "A conflict means the same skill exists twice: once here, once in"
        echo "$TARGET_DIR. Pick one source of truth before they drift apart."
    fi
fi
