#!/usr/bin/env bash
# =============================================================================
# SDD v3 — Project Sync / Checkpoint
# scripts/sync-project.sh
# Usage: ./scripts/sync-project.sh
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
CONTEXT_SCRIPT="./scripts/generate-new-agent-context.sh"
OUTPUT_FILE="context-for-new-agent.md"

# ─── Validation: Git Repo ────────────────────────────────────────────────────
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not inside a git repository."
    exit 1
fi

# ─── Step 1: Regenerate Context ──────────────────────────────────────────────
if [[ -f "$CONTEXT_SCRIPT" ]]; then
    echo "Regenerating $OUTPUT_FILE before checkpoint..."
    "$CONTEXT_SCRIPT"
else
    echo "Warning: Context generator not found at $CONTEXT_SCRIPT. Skipping context update."
fi

# ─── Step 2: Inspect State ───────────────────────────────────────────────────
echo "Inspecting project state..."
if [[ -z "$(git status --porcelain)" ]]; then
    echo "Current project state is already clean. Nothing to sync."
    exit 0
fi

# ─── Step 3: Stage Changes ───────────────────────────────────────────────────
echo "Staging all project changes..."
git add .

# ─── Step 4: Create Checkpoint Commit ────────────────────────────────────────
TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
COMMIT_MSG="chore(sync): project checkpoint [$TIMESTAMP]"

echo "Creating checkpoint: $COMMIT_MSG"
if git commit -m "$COMMIT_MSG"; then
    echo "✓ Project state successfully synchronized."
    echo "Commit: $(git rev-parse --short HEAD)"
else
    echo "Error: Failed to create checkpoint commit."
    exit 1
fi

echo ""
echo "Note: Automatic push is disabled. Use 'git push' to sync with remote if configured."
