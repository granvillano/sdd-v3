# SDD v3 — Tooling Helpers

This directory contains utility scripts to automate the SDD v3 workflow.

## 1. Run Ticket
Loads a ticket description from `docs/tickets.md` into `jobs/inbox.md`.
```bash
./scripts/run-ticket.sh <TICKET_ID>
```
**Example:** `./scripts/run-ticket.sh TICK-007`

## 2. Close Ticket
Archives the current inbox, updates logs, runs validations, and commits the work to the `dev` branch.
```bash
./scripts/close-ticket.sh <TICKET_ID> "<COMMIT_MESSAGE>"
```
**Example:** `./scripts/close-ticket.sh TICK-007 "feat(auth): implement user registration endpoint [TICKET-007]"`

---

## 🛡️ Branching Policy
- **Active Development**: All ticket implementation and closure MUST happen on the `dev` branch.
- **Stable Code**: The `main` branch is reserved for stable, integrated code only.
- **Automation**: `close-ticket.sh` automatically ensures you are on the `dev` branch before committing. It will create `dev` from `main` if it doesn't already exist.
- **Merging**: Merging from `dev` to `main` should be done manually or via a separate release workflow once a phase is complete.

### 3. Closure Automation (Close Ticket)
Found in `scripts/close-ticket.sh`. This script:
- Enforces branch policy (closure on `dev`).
- Runs validations (`npm test`, `npm run build`).
- Archives the task and updates `docs/implementation-log.md`.
- Automatically captures the commit hash and rollback info.
- **New**: Regenerates `CHANGELOG.md` from real implementation data.
- **New**: Hardens inbox cleanup and restores the task placeholder.

### 4. Changelog Automation (Generate Changelog)
Found in `scripts/generate-changelog.sh`. This script:
- Idempotently updates `CHANGELOG.md` based on `docs/implementation-log.md`.
- Maps log entries to standard "Added", "Changed", "Fixed" categories.

### 5. Context Generator (New Agent Context)
Found in `scripts/generate-new-agent-context.sh`. This script:
- Generates `context-for-new-agent.md` in the project root.
- Extracts real-time project state (Phase, Gate, Logs, Tickets).
- Provides a handoff artifact for starting new AI chats with full project awareness.

## ⚙️ Pre-commit Validation
The `close-ticket.sh` script automatically runs the project's default test and build commands (e.g., `npm test`, `npm run build`) before finalizing any records.

The closure will abort if either check fails.
