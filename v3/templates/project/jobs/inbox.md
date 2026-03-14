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

### TASK — Framework improvement: initialize Git automatically and document repository structure in new projects

You are working on the **SDD v3 framework**, not on a single project.

Goal:
Improve project bootstrap so every new SDD project starts with Git tracking active from day zero and with the repository structure documented clearly enough for new agents and developers.

This is a framework-level change and must be implemented in the framework repository.

## What must be improved

### 1. Git initialization at project creation
When `sdd-init.sh` creates a new project, it should also initialize Git automatically inside the new project root.

Required:
- run `git init` automatically
- ensure the project starts with tracking active immediately
- do not require the user to remember doing this manually later

### 2. Initial repository state
Decide and implement the best initial Git state for new projects.

Evaluate and, if appropriate, implement:
- initial commit automatically created after scaffold
- optional creation of `dev` branch if that matches the current SDD workflow
- safe behavior if Git is unavailable on the machine

If you choose not to auto-commit, explain why.
If you choose not to auto-create `dev`, explain why.

### 3. Base `.gitignore`
Ensure new projects are scaffolded with a proper `.gitignore` from the framework.

It should cover at least:
- `.DS_Store`
- `.env`
- `node_modules/`
- `dist/`
- common temporary files

Adapt it reasonably to the project profile if needed.

### 4. Repository structure must be documented in the project itself
Right now the high-level repository structure is mostly implicit by convention.

New projects should include an explicit documentation of the repository structure, for example:
- `src/` = application code
- `docs/` = SSOT documentation
- `jobs/` = task inbox
- `prompts/` = AI execution prompts
- `scripts/` = project operational tooling
- other top-level folders as appropriate

Decide the best place for this documentation.
Preferred options:
- a section in `docs/architecture.md`
- or an initial ADR
- or both if justified

The important thing is that the structure is documented in the project, not only implied by framework conventions.

### 5. Improve `generate-new-agent-context`
The generated `context-for-new-agent.md` should include the repository structure explicitly.

It should help a new agent understand:
- what each top-level folder is for
- what the important SSOT files are
- whether the project is still at bootstrap / Phase 1
- what the next expected steps are in an empty newly-created project

### 6. Better behavior for brand-new projects
For a freshly created project with empty docs, the generated context should clearly explain:
- the project is newly bootstrapped
- no implementation exists yet
- no `src/` may exist yet and that is normal
- the next expected steps are to fill `PROJECT_BRIEF.md`, `docs/spec.md`, `docs/architecture.md`, `docs/api-contract.md`, and `docs/tickets.md`

This should be explicit so a new agent does not misread an empty scaffold as a broken project.

### 7. Decide when repository-structure documentation must be updated
Define a rule for when the project must update its documented repository structure.

Provide a recommendation such as:
- initial structure documented at bootstrap
- update required whenever top-level repository layout changes
- update `context-for-new-agent.md` when structure or workflow changes materially

## Files to inspect first

Framework:
- `tools/sdd-init.sh`
- `README.md`
- `CHANGELOG.md`
- `templates/project/`
- current template docs and scripts
- current `generate-new-agent-context` scaffolding

Project examples for reference:
- project `docs/architecture.md`
- project `docs/00_INDEX.md`
- project `context-for-new-agent.md`

## Required deliverables

At the end provide:
1. what files in the framework were changed
2. whether Git init is now automatic
3. whether an initial commit is created
4. whether `dev` is created automatically or not
5. where repository structure is documented in new projects
6. how `generate-new-agent-context` was improved for new/empty projects
7. any migration note for already-existing projects

## Mandatory framework protocol

Because this is a framework change, you must also:
- update framework `CHANGELOG.md`
- update framework `README.md` if workflow or bootstrap behavior changed
- create the required audit note in `audits/`
- follow the normal framework change protocol

Respond in Spanish in the chat.
