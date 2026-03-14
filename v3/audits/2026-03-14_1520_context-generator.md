# Audit Report — New Agent Context Generator (Normalized Exposure)

Date: 2026-03-14T15:20:00Z
Framework Version: v3.11.0
Objective: Implement a project-relative context generator for AI handoff and normalize command exposure.

## Changes

1.  **New Generator Script**: `v3/templates/project/scripts/generate-new-agent-context.sh`
    - Dynamically extracts project metadata from `sdd.config.yml`.
    - Synthesizes implementation history and pending tickets.
    - Standardizes initial agent behavior rules (read-only, minimal response).
2.  **Standardized Command Exposure**:
    - Standardized the use of `/usr/local/bin` shims for all workflow commands.
    - Added `generate-new-agent-context` to the global shim set.
    - Implemented shims using a project-agnostic `git rev-parse` pattern.
3.  **Command Discovery Tools**:
    - Added `v3/tools/install-global-commands.sh` to automate shim setup/refresh.
    - Updated `v3/tools/sdd-init.sh` to include the new generator and provide global command installation instructions.
4.  **Documentation**:
    - Updated framework `CHANGELOG.md` to v3.11.0.
    - Updated framework `README.md` with usage and installation instructions.

## Verification

- Command `generate-new-agent-context` verified to resolve from `/usr/local/bin/`.
- Command correctly resolves the project root and executes the project-local script.
- Validated output `context-for-new-agent.md` contains accurate real-time data.
- Verified removal of legacy/inconsistent `~/.local/bin` shims.
