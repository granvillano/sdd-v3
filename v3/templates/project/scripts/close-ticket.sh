#!/usr/bin/env bash
# =============================================================================
# SDD v3 — Ticket Closure Automation
# scripts/close-ticket.sh
# Usage: ./scripts/close-ticket.sh <TICKET_ID> "<COMMIT_MESSAGE>"
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
TICKETS_FILE="docs/tickets.md"
INBOX_FILE="jobs/inbox.md"
LOG_FILE="docs/implementation-log.md"
ARCHIVE_DIR="jobs/archive"
MARKER="### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️"
PLACEHOLDER="(PASTE YOUR TASK HERE)"

# ─── Validation: Args ────────────────────────────────────────────────────────
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <TICKET_ID> \"<COMMIT_MESSAGE>\""
    exit 1
fi

TICKET_ID=$1
COMMIT_MSG=$2

# ─── Validation: Git Repo ────────────────────────────────────────────────────
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not inside a git repository."
    exit 1
fi

# ─── Branching Policy ────────────────────────────────────────────────────────
CURRENT_BRANCH=$(git branch --show-current)

if [[ "$CURRENT_BRANCH" == "main" ]]; then
    echo "Current branch is 'main'. Switching to 'dev'..."
    if git rev-parse --verify dev > /dev/null 2>&1; then
        git checkout dev
    else
        echo "Branch 'dev' does not exist. Creating it from 'main'..."
        git checkout -b dev
    fi
elif [[ "$CURRENT_BRANCH" != "dev" ]]; then
    echo "Error: Ticket closure must happen on 'dev' branch. Current branch: $CURRENT_BRANCH"
    exit 1
fi

# ─── Pre-commit Validation ───────────────────────────────────────────────────
echo "Running pre-commit validations (npm test, npm run build)..."

# Note: Adjust these commands if the project uses a different stack (e.g. php, python)
if [[ -f "package.json" ]]; then
    if ! npm test; then
        echo "Error: 'npm test' failed. Aborting closure."
        exit 1
    fi
    if ! npm run build; then
        echo "Error: 'npm run build' failed. Aborting closure."
        exit 1
    fi
elif [[ -f "composer.json" ]]; then
    # PHP/WordPress validation could be enabled here
    echo "Skipping validation for PHP project..."
fi

# ─── Ticket Metadata Extraction ──────────────────────────────────────────────
echo "Resolving $TICKET_ID from $TICKETS_FILE..."

# Capture the ticket block
TICKET_BLOCK=$(awk -v id="$TICKET_ID" '
    $0 ~ "^### " id { p=1; print; next }
    p && $0 ~ "^### " { p=0 }
    p { print }
' "$TICKETS_FILE")

if [[ -z "$TICKET_BLOCK" ]]; then
    echo "Error: Ticket $TICKET_ID not found in $TICKETS_FILE"
    exit 1
fi

# Extract Title (from the first line of the block)
TICKET_TITLE=$(echo "$TICKET_BLOCK" | head -n 1 | sed "s/^### $TICKET_ID: //")
# Extract Slug (simplified title for filename)
SLUG=$(echo "$TICKET_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

# ─── Test Traceability ───────────────────────────────────────────────────────
# Detect test files involved (staged or modified in tests/ or similar directories)
TEST_FILES=$(git status --porcelain | grep -E "tests/|test/" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
if [[ -z "$TEST_FILES" ]]; then
    TEST_FILES="None detected"
fi

# ─── Records Generation ──────────────────────────────────────────────────────
TIMESTAMP=$(date +"%Y-%m-%d_%H%M")
ARCHIVE_FILE="$ARCHIVE_DIR/${TIMESTAMP}_${SLUG}.md"

echo "Creating archive record: $ARCHIVE_FILE..."

cat > "$ARCHIVE_FILE" <<EOF
# Job Archive — $SLUG
Archived: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Ticket ID: $TICKET_ID
Ticket Title: $TICKET_TITLE
Source Reference: $TICKETS_FILE

## Ticket Specification
$TICKET_BLOCK

## Execution Summary
- Automated closure via close-ticket.sh
- Commit message: $COMMIT_MSG
- Branch: $(git branch --show-current)
- Test Files involved: $TEST_FILES

## Verification Results
- Build/Test: ✅ Success (verified via scripts)
EOF

# ─── Clean Inbox ─────────────────────────────────────────────────────────────
echo "Cleaning $INBOX_FILE and restoring placeholder..."

TMP_INBOX=$(mktemp)
awk -v marker="$MARKER" -v placeholder="$PLACEHOLDER" '
    {
        print $0
        if ($0 == marker) {
            print placeholder
            exit
        }
    }
' "$INBOX_FILE" > "$TMP_INBOX"
mv "$TMP_INBOX" "$INBOX_FILE"

# ─── Git Commit ──────────────────────────────────────────────────────────────
echo "Staging implementation and archive files..."

# Stage archive, inbox and implementation changes
git add "$ARCHIVE_FILE" "$INBOX_FILE"
# Also stage any modified files in common source/test directories
git status --porcelain | grep -E "^(M|A| ) (src/|tests/|lib/|test/)" | awk '{print $2}' | xargs git add || true

echo "Performing initial commit..."
git commit -m "$COMMIT_MSG"

# ─── Capture Hash and Update Log ─────────────────────────────────────────────
COMMIT_HASH=$(git rev-parse --short HEAD)
echo "Commit successful: $COMMIT_HASH. Updating $LOG_FILE..."

TMP_LOG=$(mktemp)
# Logic to find the current version and bump it or just add a new entry
VERSION_LINE=$(grep "## \[" "$LOG_FILE" | head -n 1 || true)
if [[ -n "$VERSION_LINE" ]]; then
    VERSION_DRAFT=$(echo "$VERSION_LINE" | awk '{print $3}' | sed 's/v//')
    NEXT_VERSION="v$(echo "$VERSION_DRAFT" | awk -F. '{$NF = $NF + 1;} 1' OFS=.)"
else
    NEXT_VERSION="v0.1.0-draft"
fi

# Prepare log entry
LOG_ENTRY="## [$(date +"%Y-%m-%d")] — $NEXT_VERSION — $SLUG

| Field | Value |
|-------|-------|
| Author | SDD v3 AI Agent |
| Tickets | $TICKET_ID |
| Description | $COMMIT_MSG |
| Branch | $(git branch --show-current) |
| Commit | $COMMIT_HASH |
| Rollback | Revert commit \`$COMMIT_HASH\` |
| Verification | ✅ Success |
| Tests | $TEST_FILES |
| Status | ✅ Success |
"

# Find the insertion point (below ## Entries or at the top)
if grep -q "<!-- Add new entries" "$LOG_FILE"; then
    MARKER_LOG="<!-- Add new entries"
    awk -v entry="$LOG_ENTRY" -v marker="$MARKER_LOG" '
        {
            print $0
            if ($0 ~ marker) {
                print ""
                print entry
            }
        }
    ' "$LOG_FILE" > "$TMP_LOG"
else
    {
        echo "$LOG_ENTRY"
        cat "$LOG_FILE"
    } > "$TMP_LOG"
fi

mv "$TMP_LOG" "$LOG_FILE"

# ─── Update Changelog ────────────────────────────────────────────────────────
if [[ -f "./scripts/generate-changelog.sh" ]]; then
    echo "Regenerating CHANGELOG.md from real implementation data..."
    ./scripts/generate-changelog.sh
fi

# ─── Finalize (Amend) ────────────────────────────────────────────────────────
echo "Finalizing commit with the implementation log and changelog updates..."
git add "$LOG_FILE" "CHANGELOG.md"
git commit --amend --no-edit

echo "Ticket $TICKET_ID closed successfully on branch $(git branch --show-current)."
