#!/usr/bin/env bash
# =============================================================================
# SDD v3 — Changelog Generator
# scripts/generate-changelog.sh
# Automatically updates CHANGELOG.md from docs/implementation-log.md
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
LOG_FILE="docs/implementation-log.md"
CHANGELOG_FILE="CHANGELOG.md"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Implementation log not found at $LOG_FILE"
    exit 1
fi

if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "Error: Changelog not found at $CHANGELOG_FILE"
    exit 1
fi

# ─── Extraction ──────────────────────────────────────────────────────────────
echo "Generating changelog entries from $LOG_FILE..."

# Create a temporary file for the unreleased content
TMP_UNRELEASED=$(mktemp)

# Parse logic:
# Extract entries from the implementation log and map them to Keep a Changelog types.
awk '
    BEGIN { in_entry=0; desc=""; type="" }
    /^## \[/ { 
        if (in_entry && desc != "") {
            print "- " desc
        }
        in_entry=1; desc=""; next 
    }
    in_entry && /\| Description \|/ {
        # Extract content between pipes
        sub(/^[ \t]*\| Description \|[ \t]*/, "")
        sub(/[ \t]*\|[ \t]*$/, "")
        desc = $0
        
        # Simple mapping to Keep a Changelog types
        if (tolower(desc) ~ /^feat/ || tolower(desc) ~ /implement/) type="Added"
        else if (tolower(desc) ~ /^fix/) type="Fixed"
        else if (tolower(desc) ~ /^chore/ || tolower(desc) ~ /update/ || tolower(desc) ~ /refine/) type="Changed"
        else type="Added"
        
        # Store by type
        entries[type] = entries[type] "\n- " desc
    }
    END {
        print "### Added"
        if (entries["Added"] != "") print entries["Added"]
        else print "- (None)"
        print ""
        print "### Changed"
        if (entries["Changed"] != "") print entries["Changed"]
        else print "- (None)"
        print ""
        print "### Fixed"
        if (entries["Fixed"] != "") print entries["Fixed"]
        else print "- (None)"
    }
' "$LOG_FILE" > "$TMP_UNRELEASED"

# ─── Update CHANGELOG.md ─────────────────────────────────────────────────────
echo "Updating $CHANGELOG_FILE..."

TMP_CHANGELOG=$(mktemp)

# Replace the block between ## [Unreleased] and the next ## version or separator
awk -v unreleased_file="$TMP_UNRELEASED" '
    BEGIN { p=1; done=0 }
    /^## \[Unreleased\]/ {
        print $0
        # Read the generated content
        while ((getline line < unreleased_file) > 0) {
            print line
        }
        p=0
        next
    }
    !p && /^## \[/ { p=1 }
    !p && /^---/ { p=1 }
    p { print }
' "$CHANGELOG_FILE" > "$TMP_CHANGELOG"

mv "$TMP_CHANGELOG" "$CHANGELOG_FILE"
rm "$TMP_UNRELEASED"

echo "CHANGELOG.md updated successfully."
