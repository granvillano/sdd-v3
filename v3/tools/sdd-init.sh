#!/usr/bin/env bash
# =============================================================================
# SDD v3 — Project Initializer
# tools/sdd-init.sh
# Version: 3.3.5
# =============================================================================
# Usage:
#   bash sdd-init.sh --project <project-name> --profile <profile-id>
#
# The project name must be a SIMPLE NAME only (no slashes, no paths, no ~).
# All projects are created automatically inside:
#   ~/Desktop/projects/<project-name>
#
# Options:
#   --project   REQUIRED. Project name only (e.g. "VTC-API-Node", "my-app").
#               Must NOT contain "/" or "~" or spaces.
#               The full path is resolved as: ~/Desktop/projects/<project-name>
#   --profile   REQUIRED. Profile ID. One of:
#                 php-wordpress-api
#                 node-typescript-api
#                 python-fastapi-api
#                 react-webapp
#                 react-native-app
#   --name      Optional. Display name for the project (used in sdd.config.yml
#               and documentation). Defaults to the value of --project.
#   --help      Show this help message.
#
# Examples:
#   bash sdd-init.sh --project VTC-API-Node --profile node-typescript-api
#   bash sdd-init.sh --project my-wp-plugin --profile php-wordpress-api --name "My WP Plugin"
#
# ERROR: Passing a path is rejected:
#   bash sdd-init.sh --project ~/projects/foo  ← FAILS with clear error
#   bash sdd-init.sh --project /home/user/foo  ← FAILS with clear error
# =============================================================================

set -euo pipefail

# ─── Constants ────────────────────────────────────────────────────────────────
SDD_VERSION="3.12.0"
PROJECTS_ROOT="$HOME/Desktop/projects"

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Resolve SDD v3 root ─────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDD_V3_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$SDD_V3_ROOT/templates/project"

# ─── Valid profiles ───────────────────────────────────────────────────────────
VALID_PROFILES=("php-wordpress-api" "node-typescript-api" "python-fastapi-api" "react-webapp" "react-native-app")

# ─── Functions ────────────────────────────────────────────────────────────────
print_header() {
  echo -e "\n${BOLD}${BLUE}══════════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${BLUE}   SDD v3 — Project Initializer  (v${SDD_VERSION})   ${RESET}"
  echo -e "${BOLD}${BLUE}══════════════════════════════════════════════${RESET}\n"
}

print_step() {
  echo -e "${GREEN}▶ $1${RESET}"
}

print_warn() {
  echo -e "${YELLOW}⚠  $1${RESET}"
}

print_error() {
  echo -e "${RED}✗  ERROR: $1${RESET}" >&2
}

print_success() {
  echo -e "${GREEN}✓  $1${RESET}"
}

usage() {
  cat <<EOF

${BOLD}Usage:${RESET}
  bash sdd-init.sh --project <project-name> --profile <profile-id> [--name "Display Name"]

${BOLD}Description:${RESET}
  Creates a new SDD v3 project inside the canonical projects root:
    ${BOLD}~/Desktop/projects/<project-name>${RESET}

  The --project flag accepts a project NAME only.
  Do NOT pass a path — the directory is resolved automatically.

${BOLD}Profiles:${RESET}
  php-wordpress-api     PHP 8.2+ / WordPress Plugin REST API
  node-typescript-api   Node.js 20 / TypeScript / Express or Fastify
  python-fastapi-api    Python 3.11+ / FastAPI
  react-webapp          React 18+ / TypeScript / Vite or Next.js
  react-native-app      React Native / Expo / TypeScript

${BOLD}Valid examples:${RESET}
  bash sdd-init.sh --project VTC-API-Node --profile node-typescript-api
  bash sdd-init.sh --project my-wp-plugin --profile php-wordpress-api --name "My WP Plugin"
  bash sdd-init.sh --project FastAPI-Booking --profile python-fastapi-api

${BOLD}Invalid (will fail):${RESET}
  bash sdd-init.sh --project ~/myproject ...       ← path not allowed
  bash sdd-init.sh --project /home/user/foo ...    ← path not allowed
  bash sdd-init.sh --project my/nested/name ...    ← slashes not allowed

${BOLD}Projects root:${RESET}
  $PROJECTS_ROOT

EOF
  exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
PROJECT_ARG=""
PROFILE=""
PROJECT_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ARG="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --name)    PROJECT_NAME="$2"; shift 2 ;;
    --help|-h) usage ;;
    *) print_error "Unknown option: $1"; usage ;;
  esac
done

# ─── Validation: required args ────────────────────────────────────────────────
if [[ -z "$PROJECT_ARG" ]]; then
  print_error "--project is required."
  usage
fi

if [[ -z "$PROFILE" ]]; then
  print_error "--profile is required."
  usage
fi

# ─── Validation: project arg must be a NAME only (no paths) ──────────────────
if [[ "$PROJECT_ARG" == /* ]] || \
   [[ "$PROJECT_ARG" == ~* ]] || \
   [[ "$PROJECT_ARG" == */* ]] || \
   [[ "$PROJECT_ARG" =~ [[:space:]] ]]; then
  echo -e "${RED}✗  ERROR: --project must be a project name only.${RESET}" >&2
  echo -e "${RED}   Projects are created automatically inside ~/Desktop/projects${RESET}" >&2
  echo -e "${RED}   Invalid value: \"$PROJECT_ARG\"${RESET}" >&2
  echo "" >&2
  echo -e "${YELLOW}   Correct usage:${RESET}" >&2
  echo -e "${YELLOW}     bash sdd-init.sh --project VTC-API-Node --profile node-typescript-api${RESET}" >&2
  echo "" >&2
  exit 1
fi

# ─── Resolve full project path ────────────────────────────────────────────────
PROJECT_PATH="$PROJECTS_ROOT/$PROJECT_ARG"

# ─── Validation: idempotency guard ───────────────────────────────────────────
if [[ -d "$PROJECT_PATH" ]]; then
  echo -e "${RED}✗  ERROR: Project directory already exists: $PROJECT_PATH${RESET}" >&2
  echo -e "${RED}   SDD init is non-destructive. Will not overwrite an existing project.${RESET}" >&2
  echo -e "${YELLOW}   To reinitialize, remove or rename the existing directory first.${RESET}" >&2
  exit 1
fi

# ─── Validation: profile ─────────────────────────────────────────────────────
PROFILE_VALID=false
for p in "${VALID_PROFILES[@]}"; do
  [[ "$p" == "$PROFILE" ]] && PROFILE_VALID=true && break
done

if [[ "$PROFILE_VALID" == "false" ]]; then
  print_error "Invalid profile: '$PROFILE'. Valid options: ${VALID_PROFILES[*]}"
  exit 1
fi

# ─── Validation: SDD v3 structure ────────────────────────────────────────────
if [[ ! -d "$SDD_V3_ROOT/core" ]]; then
  print_error "SDD v3 core not found at $SDD_V3_ROOT/core. Is the framework installed?"
  exit 1
fi

if [[ ! -d "$SDD_V3_ROOT/profiles/$PROFILE" ]]; then
  print_error "Profile directory not found: $SDD_V3_ROOT/profiles/$PROFILE"
  exit 1
fi

# ─── Resolve display name ─────────────────────────────────────────────────────
if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="$PROJECT_ARG"
fi

INIT_DATE="$(date +%Y-%m-%d)"

# ─── Begin initialization ─────────────────────────────────────────────────────
print_header
echo -e "  ${BOLD}Project name:${RESET} $PROJECT_NAME"
echo -e "  ${BOLD}Project root:${RESET} $PROJECT_PATH"
echo -e "  ${BOLD}Profile:${RESET}      $PROFILE"
echo -e "  ${BOLD}Date:${RESET}         $INIT_DATE"
echo -e "  ${BOLD}SDD Version:${RESET}  $SDD_VERSION"
echo ""

# Step 1: Create project directory structure
print_step "Creating project directory structure..."
mkdir -p "$PROJECTS_ROOT"
mkdir -p "$PROJECT_PATH"/{docs/{adr,changes},jobs/archive,inputs,prompts,scripts}

print_success "Directory structure created: $PROJECT_PATH"

# Step 2: Create inputs/README.md
print_step "Creating inputs/ external reference area..."

cat > "$PROJECT_PATH/inputs/README.md" <<'INPUTS_README'
# inputs/ — External Reference Zone

> **SDD v3.2.2 — Mandatory External Inputs Area**

---

## Purpose

The `inputs/` directory is the **dedicated zone for external reference materials**
that the AI agent MUST scan before beginning any job.

---

## Rules

| Rule | Detail |
|------|--------|
| **Read-only for AI** | Agents may read and summarize; they must NEVER modify, delete, or move files in this directory. |
| **Human-managed** | Only humans add or remove files from `inputs/`. |
| **Scanned before every job** | The PRE-JOB INPUTS SCAN (see `prompts/02-agent-entrypoint.md` STEP 0) is mandatory when this directory is non-empty. |
| **Not mixed with docs/** | Reference files belong here, not in `docs/`. The `docs/` directory is for agent-generated output. |

---

## What to place here

- Existing codebase dumps or file trees (Brownfield)
- Third-party API documentation (PDF, Markdown, HTML)
- Business requirement documents from clients
- Legacy architecture diagrams or data schemas
- Compliance or legal constraints documents
- Design assets or brand guidelines

---

## Greenfield vs Brownfield

| State | Condition | Impact |
|-------|-----------|--------|
| **Greenfield** | `inputs/` is empty (only this README) | Agent starts from scratch with no external constraints. |
| **Brownfield** | `inputs/` contains files | Agent MUST run the full PRE-JOB INPUTS SCAN and declare Brownfield mode. Traceability gate fails if no scan evidence is recorded. |

---

## Scan Evidence

When the agent completes the PRE-JOB INPUTS SCAN, it records evidence in:

```
docs/changes/YYYY-MM-DD_HHMM_<slug>.md
```

This evidence file is checked by QG-2 (ARCHITECTURE GATE).
INPUTS_README

print_success "inputs/README.md created."

# Step 3: Copy templates
print_step "Copying SDD v3 project templates..."

# Git initialization (Early, before copying templates to track them)
if command -v git >/dev/null 2>&1; then
  print_step "Initializing Git repository..."
  git init -q "$PROJECT_PATH"
  # Set default branch to main if not configured
  git -C "$PROJECT_PATH" checkout -b main 2>/dev/null || true
else
  print_warn "Git not found. Skipping repository initialization."
fi

# Copy .gitignore first
if [[ -f "$TEMPLATES_DIR/.gitignore" ]]; then
  cp "$TEMPLATES_DIR/.gitignore" "$PROJECT_PATH/.gitignore"
fi

# prompts/ — canonical user-facing directory
cp "$TEMPLATES_DIR/prompts/00-run.md"               "$PROJECT_PATH/prompts/00-run.md"
cp "$TEMPLATES_DIR/prompts/00-start-job.md"         "$PROJECT_PATH/prompts/00-start-job.md"
cp "$TEMPLATES_DIR/prompts/02-agent-entrypoint.md"  "$PROJECT_PATH/prompts/02-agent-entrypoint.md"
cp "$TEMPLATES_DIR/jobs/inbox.md"                   "$PROJECT_PATH/jobs/inbox.md"
cp "$TEMPLATES_DIR/docs/implementation-log.md"      "$PROJECT_PATH/docs/implementation-log.md"
cp "$TEMPLATES_DIR/docs/00_INDEX.md"                "$PROJECT_PATH/docs/00_INDEX.md"
cp "$TEMPLATES_DIR/scripts/run-ticket.sh"                "$PROJECT_PATH/scripts/run-ticket.sh"
cp "$TEMPLATES_DIR/scripts/close-ticket.sh"              "$PROJECT_PATH/scripts/close-ticket.sh"
cp "$TEMPLATES_DIR/scripts/generate-changelog.sh"        "$PROJECT_PATH/scripts/generate-changelog.sh"
cp "$TEMPLATES_DIR/scripts/generate-new-agent-context.sh" "$PROJECT_PATH/scripts/generate-new-agent-context.sh"
cp "$TEMPLATES_DIR/scripts/README.md"                    "$PROJECT_PATH/scripts/README.md"
cp "$TEMPLATES_DIR/PROJECT_BRIEF.template.md"       "$PROJECT_PATH/PROJECT_BRIEF.md"

# Set execution permissions for the helper scripts
chmod +x "$PROJECT_PATH/scripts/run-ticket.sh"
chmod +x "$PROJECT_PATH/scripts/close-ticket.sh"
chmod +x "$PROJECT_PATH/scripts/generate-changelog.sh"
chmod +x "$PROJECT_PATH/scripts/generate-new-agent-context.sh"

# Substitute project name in copied files
sed -i.bak "s/\[PROJECT NAME\]/$PROJECT_NAME/g" "$PROJECT_PATH/docs/implementation-log.md" 2>/dev/null && rm -f "$PROJECT_PATH/docs/implementation-log.md.bak"
sed -i.bak "s/\[PROJECT NAME\]/$PROJECT_NAME/g" "$PROJECT_PATH/docs/00_INDEX.md" 2>/dev/null && rm -f "$PROJECT_PATH/docs/00_INDEX.md.bak"
sed -i.bak "s/\[PROJECT NAME\]/$PROJECT_NAME/g" "$PROJECT_PATH/PROJECT_BRIEF.md" 2>/dev/null && rm -f "$PROJECT_PATH/PROJECT_BRIEF.md.bak"
sed -i.bak "s/\[YYYY-MM-DD\]/$INIT_DATE/g"      "$PROJECT_PATH/PROJECT_BRIEF.md" 2>/dev/null && rm -f "$PROJECT_PATH/PROJECT_BRIEF.md.bak"

print_success "Templates copied."

# Step 4: Generate sdd.config.yml
print_step "Generating sdd.config.yml..."

cat > "$PROJECT_PATH/sdd.config.yml" <<YAML
# sdd.config.yml — SDD v3 Project Configuration
# Generated by sdd-init.sh v${SDD_VERSION} on $INIT_DATE
# DO NOT REMOVE THIS FILE — agents use it for context loading.

sdd_version: "${SDD_VERSION}"
project_name: "$PROJECT_NAME"
project_slug: "$PROJECT_ARG"
profile: "$PROFILE"
sdd_v3_root: "$SDD_V3_ROOT"
project_root: "$PROJECT_PATH"

# Active lifecycle phase (1–7). Update as the project progresses.
active_phase: 1

# Last quality gate passed. Update after each gate.
# Values: none | QG-1 | QG-2 | QG-3 | QG-4 | QG-5
last_gate_passed: none

# Team configuration
team:
  product_owner: ""        # fill in
  tech_lead: ""            # fill in
  security_contact: ""     # fill in

# Quality settings (profile defaults apply unless overridden here)
quality:
  min_coverage: 80          # percentage
  max_lint_warnings: 0
  sast_enabled: true
  secret_scan_enabled: true

# Documentation paths (relative to project root)
docs:
  spec: docs/spec.md
  architecture: docs/architecture.md
  api_contract: docs/api-contract.md
  implementation_log: docs/implementation-log.md
  tickets: docs/tickets.md
  test_plan: docs/test-plan.md
  changelog: CHANGELOG.md

# Inputs area (external reference zone — read-only for agents)
inputs:
  path: inputs/
  scan_required_if_non_empty: true
YAML

print_success "sdd.config.yml created."

# Step 5: Create placeholder docs
print_step "Creating placeholder documents..."

touch "$PROJECT_PATH/docs/spec.md"
touch "$PROJECT_PATH/docs/architecture.md"
touch "$PROJECT_PATH/docs/api-contract.md"
touch "$PROJECT_PATH/docs/tickets.md"
touch "$PROJECT_PATH/docs/test-plan.md"
touch "$PROJECT_PATH/CHANGELOG.md"
touch "$PROJECT_PATH/SECURITY.md"

cat > "$PROJECT_PATH/CHANGELOG.md" <<CHANGELOG
# Changelog

All notable changes to this project will be documented in this file.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning](https://semver.org/)

## [Unreleased]

## [0.0.1] — $INIT_DATE
### Added
- Project initialized with SDD v3 framework v${SDD_VERSION} (profile: $PROFILE)
CHANGELOG

cat > "$PROJECT_PATH/SECURITY.md" <<SECURITY
# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest  | ✅ Yes    |

## Reporting a Vulnerability

Please report security vulnerabilities to: [FILL IN SECURITY CONTACT]

Do NOT open a public GitHub issue for security vulnerabilities.

Expected response time: 48 hours.
SECURITY

print_success "Placeholder documents created."

# Step 6: Initial Git Commit
if command -v git >/dev/null 2>&1 && [[ -d "$PROJECT_PATH/.git" ]]; then
  print_step "Creating initial bootstrap commit..."
  (
    cd "$PROJECT_PATH"
    git add .
    git commit -m "feat: initial bootstrap [SDD v3]" -m "Project initialized with SDD v3 framework v${SDD_VERSION} (profile: $PROFILE)" -q
    git checkout -b dev 2>/dev/null || true
    print_success "Git repository initialized with initial commit on branch 'dev'."
  )
fi

# ─── Final Summary ────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}   ✓ SDD v3 project initialized successfully!  ${RESET}"
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo -e "  1. Fill in ${BOLD}PROJECT_BRIEF.md${RESET}"
echo -e "  2. Drop reference files into ${BOLD}inputs/${RESET} (Brownfield) or leave empty (Greenfield)"
echo -e "  3. Open ${BOLD}prompts/02-agent-entrypoint.md${RESET} — fill in project identity fields"
echo -e "  4. Paste tasks in ${BOLD}jobs/inbox.md${RESET} below the marker"
echo -e "  5. Paste ${BOLD}prompts/00-run.md${RESET} into Antigravity to trigger execution"
echo ""
echo -e "  ${BOLD}Framework:${RESET} $SDD_V3_ROOT"
echo -e "  ${BOLD}Project:${RESET}   $PROJECT_PATH"
echo -e "  ${BOLD}Inputs:${RESET}    $PROJECT_PATH/inputs/"
echo ""
