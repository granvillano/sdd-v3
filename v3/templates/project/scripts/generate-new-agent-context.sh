#!/usr/bin/env bash
# =============================================================================
# SDD v3 — New Agent Context Generator
# scripts/generate-new-agent-context.sh
# Generates context-for-new-agent.md for AI handoff
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
CONFIG_FILE="sdd.config.yml"
LOG_FILE="docs/implementation-log.md"
TICKETS_FILE="docs/tickets.md"
CHANGELOG_FILE="CHANGELOG.md"
OUTPUT_FILE="context-for-new-agent.md"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: SDD config not found at $CONFIG_FILE"
    exit 1
fi

# ─── Helper: Extract from YAML ───────────────────────────────────────────────
get_config() {
    grep "^$1:" "$CONFIG_FILE" | awk -F': ' '{print $2}' | sed 's/"//g' | sed "s/'//g"
}

# ─── Data Gathering ──────────────────────────────────────────────────────────
PROJECT_NAME=$(get_config "project_name")
PROFILE=$(get_config "profile")
PHASE=$(get_config "active_phase")
GATE=$(get_config "last_gate_passed")
SDD_ROOT=$(get_config "sdd_v3_root")
PROJECT_ROOT=$(get_config "project_root")

# Get latest version from CHANGELOG
LATEST_VERSION="Unreleased"
if [[ -f "$CHANGELOG_FILE" ]]; then
    LATEST_VERSION=$(grep "^## \[" "$CHANGELOG_FILE" | head -n 1 | sed -E 's/## \[(.*)\].*/\1/' || echo "Unreleased")
fi

# Get latest 3 log entries (just the headers)
LATEST_LOGS="No entries yet."
if [[ -f "$LOG_FILE" ]]; then
    LATEST_LOGS=$(grep "^## \[" "$LOG_FILE" | head -n 3 || echo "No entries yet.")
fi

# Get upcoming tickets
PENDING_TICKETS="No tickets found."
if [[ -f "$TICKETS_FILE" ]]; then
    PENDING_TICKETS=$(grep "### TICK-" "$TICKETS_FILE" | grep "\[ \]" | head -n 5 || true)
    if [[ -z "$PENDING_TICKETS" ]]; then
        PENDING_TICKETS=$(grep "### TICK-" "$TICKETS_FILE" | head -n 10 || echo "No tickets found.")
    fi
fi

# ─── Generation ─────────────────────────────────────────────────────────────
echo "Generating $OUTPUT_FILE from real project state..."

cat > "$OUTPUT_FILE" <<EOF
# SDD v3 Project Context — Handoff for New Agent
Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

> [!IMPORTANT]
> **TO THE NEW AGENT**: Read this file first to understand the project state, rules, and expectations. Do NOT start implementing yet. Confirm understanding briefly and ask for missing information.

## 1. Project Identity
- **Project Name:** $PROJECT_NAME
- **Profile:** $PROFILE
- **Current Phase:** Phase $PHASE
- **Last Quality Gate:** $GATE
- **Project Root:** $PROJECT_ROOT
- **Framework Root:** $SDD_ROOT

## 2. SDD v3 Workflow Summary
- **SSOT:** Documentation (\`docs/\`) is the Single Source of Truth. Code must exactly mirror the specs.
- **Git State:** Tracking is active on the \`dev\` branch. Commit per ticket.

## 3. Repository Layout & Conventions
- \`src/\`: Application source code.
- \`docs/\`: SSOT specifications and contracts.
- \`jobs/\`: Tasks (\`inbox.md\`) and \`archive/\`.
- \`prompts/\`: AI control prompts.
- \`scripts/\`: Operational scripts for ticket management.
- \`inputs/\`: External references (read-only).

## 4. Current Project State
EOF

# Detect if project is brand new (Phase 1 and empty implementation log)
IS_NEW_PROJECT=false
if [[ "$PHASE" -eq 1 ]]; then
    LOG_ENTRIES_COUNT=$(grep -c "^## \[" "$LOG_FILE" || echo "0")
    if [[ "$LOG_ENTRIES_COUNT" -le 1 ]]; then
        IS_NEW_PROJECT=true
    fi
fi

if [[ "$IS_NEW_PROJECT" == "true" ]]; then
    cat >> "$OUTPUT_FILE" <<EOF
> [!NOTE]
> **BOOTSTRAP STATE**: This project was recently scaffolded. No implementation (\`src/\`) exists yet. This is normal.
> **Next Expected Steps**: 1. Fill \`PROJECT_BRIEF.md\`, 2. Define \`docs/spec.md\`, 3. Draft \`docs/architecture.md\`.

EOF
fi

cat >> "$OUTPUT_FILE" <<EOF
- **Latest Version:** $LATEST_VERSION
- **Recent Activities (from Implementation Log):**
$(echo "$LATEST_LOGS" | sed 's/^/  /')

- **Upcoming Tickets:**
$(echo "$PENDING_TICKETS" | sed 's/^/  /')

## 5. Critical SSOT Files
- \`sdd.config.yml\`: Project configuration
- \`prompts/02-agent-entrypoint.md\`: Operational rules and identity
- \`docs/spec.md\`: Product specifications
- \`docs/architecture.md\`: System design (includes repo structure)
- \`docs/api-contract.md\`: API definitions and error standards
- \`docs/tickets.md\`: Implementation roadmap
- \`docs/implementation-log.md\`: Historical record
- \`CHANGELOG.md\`: Version history

## 6. Initial Agent Behavior Rules
1. **Listen First:** Do not start implementing or producing long speculative responses.
2. **Verify Context:** Read the SSOT files listed above to understand the current technical debt and design decisions.
3. **Minimize Noise:** Respond briefly confirming understanding.
4. **Ask Questions:** If information is missing or contradictory, ask for clarification before proceeding.
5. **Enforce Gates:** Never skip a quality gate block. If a gate isn't passed, do not proceed to implementation.
6. **Isolated Implementation:** Implement one ticket at a time. Commit and close before moving to the next.

---
*This file was auto-generated by \`generate-new-agent-context\`.*
EOF

echo "Context file generated at: $OUTPUT_FILE"
