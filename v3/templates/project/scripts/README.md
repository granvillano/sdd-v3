# SDD v3 — Tooling Helpers

This directory contains utility scripts to automate the SDD v3 workflow.

## 1. Run Ticket
Loads a ticket description from `docs/tickets.md` into `jobs/inbox.md`.
```bash
./scripts/run-ticket.sh <TICKET_ID>
```
**Example:** `./scripts/run-ticket.sh TICK-001`
**Workflow:** Use this to start work on a specific ticket from your roadmap.

## 2. Close Ticket
Archives the current inbox, updates logs, runs validations, and commits the work to the `dev` branch.
```bash
./scripts/close-ticket.sh <TICKET_ID> "<COMMIT_MESSAGE>"
```
**Example:** `./scripts/close-ticket.sh TICK-001 "feat: implement user login"`
**Workflow:** Use this to finalize a ticket. It ensures traceability and code quality.

## 3. Clear Inbox (cli-i)
Safely clears the prompt area in `jobs/inbox.md` to prepare for a new task.
```bash
./scripts/cli-i.sh
```
**Workflow:** Use this when you want to discard the current prompt area content without closing a ticket.

## 4. Generate New Agent Context
Generates `context-for-new-agent.md` with the current project state for AI handoff.
```bash
./scripts/generate-new-agent-context.sh
```
**Workflow:** Run this before starting a new chat session with an AI agent.

## 5. Sync Project
Regenerates context and creates a Git checkpoint commit of the current project state.
```bash
./scripts/sync-project.sh
```
**Workflow:** Use for end-of-day saves or manual checkpoints.

## 6. Generate Changelog
Idempotently updates `CHANGELOG.md` based on `docs/implementation-log.md`.
```bash
./scripts/generate-changelog.sh
```
**Workflow:** Automatically called by `close-ticket.sh`, but can be run manually to refresh history.

---

## 🛡️ Branching Policy
- **Active Development**: All ticket implementation and closure MUST happen on the `dev` branch.
- **Stable Code**: The `main` branch is reserved for stable, integrated code only.
- **Automation**: `close-ticket.sh` automatically ensures you are on the `dev` branch.
