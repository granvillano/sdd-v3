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

### TASK — Add `cli-i` command and fully update scripts README documentation

You are working on the **SDD v3 framework** and must also apply the resulting changes to the **current project** as part of this task.

## Goal

Create a new command called:

cli-i

Meaning:
clear inbox.

This command must safely clean the prompt area in `jobs/inbox.md`.

At the same time, you must inspect the real scripts that currently exist and regenerate the scripts README so it correctly documents **all available scripts**, both in the framework template and in the current project.

---

## Important constraint

Do NOT install the command globally in this task.

Do NOT write to `/usr/local/bin`.
Do NOT request sudo.
Do NOT create or modify global command aliases in this task.

The user will handle global installation manually later if needed.

Your job here is only to:

- create the project-local script
- scaffold it in the framework template
- apply it to the current project
- update the scripts README documentation properly

---

## `cli-i` required behavior

The command must safely clean `jobs/inbox.md` by:

1. finding this exact marker:

`### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️`

2. preserving everything above that marker unchanged

3. replacing everything below the marker with exactly:

`(PASTE YOUR TASK HERE)`

So the final relevant section must become exactly:

```md
### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️
(PASTE YOUR TASK HERE)


Safety requirements

The script must:

fail clearly if jobs/inbox.md does not exist

fail clearly if the marker is not found

never corrupt the file

be deterministic

be repeatable

work no matter how many lines are below the marker

README documentation requirement

The current scripts README is outdated.

You must:

inspect the scripts directory

detect which scripts actually exist

regenerate the README so it documents all real scripts present

Do NOT assume which scripts exist.
Do NOT document imaginary scripts.
Do NOT leave the README partially updated.

For every script that actually exists, the README should document:

script name

purpose

basic usage example

when it should be used in the workflow

Scope

You must apply this in both places:

Framework

add cli-i to the project template

update the template scripts README so future projects receive correct documentation

Current project

add cli-i to the current project

update the current project scripts README so it matches the scripts that really exist now

Files to inspect first

Framework:

tools/sdd-init.sh

template project scripts directory

template project scripts README

framework README.md

framework CHANGELOG.md

Current project:

scripts/

jobs/inbox.md

current scripts README

Required deliverables

At the end provide ONLY:

files changed in the framework

files changed in the current project

scripts detected in the scripts directory

confirmation that the scripts README now documents all existing scripts

verification result for cli-i

Mandatory framework protocol

Because this changes framework behavior, you must also:

update framework CHANGELOG.md

update framework README.md if relevant

create the required audit note in audits/

follow the normal framework change protocol

Respond in Spanish in the chat.