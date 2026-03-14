#!/usr/bin/env bash
# =============================================================================
# SDD v3 — Clear Inbox
# scripts/cli-i.sh
# Usage: ./scripts/cli-i.sh
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
INBOX_FILE="jobs/inbox.md"
MARKER="### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️"
PLACEHOLDER="(PASTE YOUR TASK HERE)"

# ─── Validation ──────────────────────────────────────────────────────────────
if [[ ! -f "$INBOX_FILE" ]]; then
    echo "Error: $INBOX_FILE not found."
    exit 1
fi

if ! grep -q "$MARKER" "$INBOX_FILE"; then
    echo "Error: Marker not found in $INBOX_FILE"
    echo "Expected: $MARKER"
    exit 1
fi

# ─── Operation ───────────────────────────────────────────────────────────────
echo "Cleaning $INBOX_FILE..."

TMP_FILE=$(mktemp)
# Preserve everything up to and including the marker, then add the placeholder
awk -v marker="$MARKER" -v placeholder="$PLACEHOLDER" '
    p { next }
    { print }
    $0 == marker {
        print placeholder
        p = 1
    }
' "$INBOX_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$INBOX_FILE"

echo "✓ Inbox cleared successfully."
