# SDD Job Inbox

> Instrucciones para el humano:
> - Solo escribe debajo del marcador `⬇️`.
> - La IA borrará todo desde el marcador hacia abajo y restaurará el placeholder cuando termine.
> - Las secciones de arriba (Blocked Items, Completed) las gestiona la IA — no las edites a mano.

---

<!-- ═══════════ BLOCKED ITEMS (agent-managed) ═══════════ -->
## 🔴 Blocked Items

| Item ID | Gate | Blocking Reason | Owner | Date Added |
|---------|------|----------------|-------|-----------|
| — | — | — | — | — |

<!-- ═══════════ COMPLETED (agent-managed) ═══════════ -->
## ✅ Completed Jobs

| Slug | Completed | Archive |
|------|-----------|---------|
| — | — | — |

---

────────────────────────────────────────────────────────
### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️

### TASK — Add project sync/checkpoint command to SDD and apply it to the current project

You are working on the **SDD v3 framework** and must also apply the resulting feature to the **current project** as part of this task.

## Goal

Create a new command called:

sync-project

This command must be usable from the **project root**, with no `./scripts/...` and no `.sh`, following the same command exposure model already used by:

- `run-ticket`
- `close-ticket`
- `generate-new-agent-context`

The command must act as a **project checkpoint / sync command** for end-of-day or manual save moments.

It should save the current state of the project into Git in a clean and repeatable way, even if there is no application code yet.

---

## What `sync-project` must do

When run from the root of a project, `sync-project` must:

1. Regenerate `context-for-new-agent.md`
   - always regenerate it before saving state

2. Inspect the working tree
   - detect modified, deleted, untracked files

3. Stage the project state
   - perform the appropriate Git add so the current project state is captured

4. Create a checkpoint commit automatically
   - commit message must include date and time
   - make the message clear that this is a project sync/checkpoint commit
   - choose a good standard format and state it explicitly

5. Work whether or not `src/` exists
   - a newly scaffolded Phase 1 project must still be handled correctly

6. Be safe and predictable
   - if there is nothing to commit, say so clearly and do not fail noisily
   - if Git is not initialized, report clearly what is missing
   - do not do a push automatically unless you explicitly justify it and make it safe
   - assume many projects may not yet have a remote configured

---

## Important design intent

This command is for:
- saving the current full state of the project
- docs
- prompts
- jobs
- scripts
- context artifacts
- code if code exists
- any project-local modifications that should be checkpointed

This is NOT a ticket-close command.
This is NOT only for src/.
This is a general project state sync/checkpoint.

---

## Required command behavior

The final command must be callable exactly as:

sync-project

from the project root.

It must not require:

- `./scripts/...`
- `bash scripts/...`
- explicit `.sh`

Use the same command exposure mechanism already used by the other SDD project commands.

---

## Framework scope

This is a framework-level change because future projects should also get this command automatically.

You must therefore:

1. add the command to the framework templates / bootstrap process
2. ensure future projects receive it automatically
3. apply it to the current project as part of this task so it can be tested now

---

## Current project requirement

Do not only modify the framework.

Also apply the new command to the **current existing project** so that after this task the command can be tested immediately in the current project.

---

## Things to decide and implement

Before implementing, decide and state:

1. exact commit message format used by `sync-project`
2. whether the command stages all project changes or uses a narrower scope
3. whether generated files like `context-for-new-agent.md` are included in the checkpoint
4. whether `CHANGELOG.md` should also be regenerated or not as part of this command
5. whether the command should refuse to run outside a Git repository
6. whether push is intentionally excluded

Then implement the chosen design.

---

## Strong guidance

Preferred behavior:
- regenerate `context-for-new-agent.md`
- `git status` inspection
- stage current project state
- create a checkpoint commit with timestamp
- no automatic push
- clear reporting in chat

If you choose something different, justify it clearly.

---

## Files and areas to inspect first

Framework:
- `tools/sdd-init.sh`
- command installer / global command exposure logic
- project templates for scripts and command wrappers
- framework `README.md`
- framework `CHANGELOG.md`

Current project:
- current command model for `run-ticket`
- current command model for `close-ticket`
- current command model for `generate-new-agent-context`
- `sdd.config.yml`
- current Git repository state

---

## Required deliverables

At the end provide ONLY:

1. files changed in framework
2. files changed in the current project
3. exact behavior of `sync-project`
4. exact commit message format
5. whether push is done or not
6. verification results from the current project

---

## Mandatory framework protocol

Because this changes framework behavior, you must also:
- update framework `CHANGELOG.md`
- update framework `README.md` if needed
- create the required audit note in `audits/`
- follow the normal framework change protocol

Respond in Spanish in the chat.