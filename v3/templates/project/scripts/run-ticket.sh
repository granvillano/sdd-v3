#!/usr/bin/env bash
# =============================================================================
# SDD v3 — Ticket Runner Helper
# scripts/run-ticket.sh
# Usage: ./scripts/run-ticket.sh <TICKET_ID>
# Example: ./scripts/run-ticket.sh TICK-007
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
TICKETS_FILE="docs/tickets.md"
INBOX_FILE="jobs/inbox.md"
MARKER="### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️"

# ─── Validation ──────────────────────────────────────────────────────────────
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <TICKET_ID>"
    exit 1
fi

TICKET_ID=$1

if [[ ! -f "$TICKETS_FILE" ]]; then
    echo "Error: Tickets file not found at $TICKETS_FILE"
    exit 1
fi

if [[ ! -f "$INBOX_FILE" ]]; then
    echo "Error: Inbox file not found at $INBOX_FILE"
    exit 1
fi

# ─── Ticket Extraction ───────────────────────────────────────────────────────
# We extract the ticket block starting from the header until the next header or EOF
echo "Extracting $TICKET_ID from $TICKETS_FILE..."

# Capture the ticket content using awk
TICKET_CONTENT=$(awk -v id="$TICKET_ID" '
    $0 ~ "^### " id { p=1; print; next }
    p && $0 ~ "^### " { p=0 }
    p { print }
' "$TICKETS_FILE")

if [[ -z "$TICKET_CONTENT" ]]; then
    echo "Error: Ticket $TICKET_ID not found in $TICKETS_FILE"
    exit 1
fi

# ─── Inbox Replacement ───────────────────────────────────────────────────────
echo "Updating $INBOX_FILE..."

# Create a temporary file
TMP_INBOX=$(mktemp)

# We use ENVIRON to pass the content to avoid shell/awk newline issues
export TICKET_CONTENT
awk -v marker="$MARKER" '
    BEGIN { found=0 }
    {
        print $0
        if ($0 == marker) {
            found=1
            exit
        }
    }
    END {
        if (found == 1) {
            print ""
            print ENVIRON["TICKET_CONTENT"]
        } else {
            exit 1
        }
    }
' "$INBOX_FILE" > "$TMP_INBOX"

if [[ $? -ne 0 ]]; then
    echo "Error: Marker not found in $INBOX_FILE"
    rm "$TMP_INBOX"
    exit 1
fi

# Atomic move
mv "$TMP_INBOX" "$INBOX_FILE"

echo "Successfully loaded $TICKET_ID into $INBOX_FILE"
