# Plugins Directory

Plugins are modular, prompt-based capabilities included in generated toolkits during `/start-here`. Each plugin is a folder with a README, optional CONFIG, and one or more prompt templates in `prompts/`.

---

## Invocation Types

Every plugin has an invocation type, set at generation time during Phase 4:

**On-demand** — a `/skill-name` slash command is generated alongside the plugin. The user invokes it when they need it. Best for ad-hoc tasks (parsing a ticket, drafting an email, writing a PR description).

**Workflow-embedded** — the plugin is referenced in a specific WORKFLOW.md step. It runs automatically when the workflow reaches that point. Best for recurring tasks that happen at a predictable moment (writing meeting notes after every meeting, generating a status report at sprint end).

The plugin folder structure is identical either way — only the generated wrapper differs.

---

## Available Plugins

### Agile Dev Loop Bundle
Offer as a group for existing-app developer toolkits.

| Plugin | What it does | Default invocation |
|---|---|---|
| `ticket-parser` | Extracts tasks, ACs, checklist items from raw Jira/Linear/GitHub ticket text | On-demand |
| `standup-summary` | Converts implementation notes into a 3–4 sentence spoken stand-up update | On-demand |
| `code-review-checklist` | Generates a targeted PR review checklist for the described change | On-demand |
| `pr-description-writer` | Generates a structured PR description from change summary and ticket ref | On-demand |

### Communication
| Plugin | What it does | Default invocation |
|---|---|---|
| `meeting-notes-writer` | Converts raw notes or transcript into structured meeting notes | On-demand or embedded |
| `status-report-writer` | Generates a project status update from progress notes and blockers | On-demand or embedded |
| `email-drafter` | Drafts a professional email from bullet points or rough context | On-demand |

### Consulting Deliverables
| Plugin | What it does | Default invocation |
|---|---|---|
| `requirements-writer` | Converts rough descriptions or meeting notes into structured requirements | On-demand |
| `loe-estimator` | Generates an LOE breakdown with sizing and assumptions from requirements | On-demand |
| `feedback-synthesizer` | Synthesizes raw feedback into themes, evidence, and recommended actions | On-demand |

---

## Plugin Status

Plugins marked **Starter** have a working prompt and README but are intentionally minimal — they are designed to be refined. The prompt templates cover the common case; users who need something different should update the prompt to match their team's conventions. This is expected and encouraged.

Fully built plugins (ticket-parser, standup-summary, code-review-checklist) have CONFIG files and handle multiple input variations.

---

## Ideas to Build

These were identified during research as commonly needed but not yet built. Add them as you discover the need:

**Dev**
- `commit-message-writer` — conventional commit message from diff/notes
- `error-explainer` — explains a stack trace and suggests root cause fixes
- `test-case-writer` — generates unit test cases from a function description
- `refactor-planner` — produces a refactor plan with rationale from a file or function
- `api-doc-writer` — generates API documentation from code or endpoint description

**Consulting**
- `risk-register-builder` — structured risk register from project context
- `proposal-writer` — engagement proposal outline from a brief or SOW input
- `presentation-outliner` — slide-by-slide outline from a brief or document
- `stakeholder-summary` — translates technical findings into non-technical language

**Analysis**
- `decision-framer` — structures a decision as options, tradeoffs, and recommendation
- `assumption-mapper` — extracts and flags assumptions from a plan or document

**Data/Technical**
- `sql-explainer` — explains what a SQL query does in plain language
- `data-dictionary-writer` — generates a data dictionary entry from schema or columns

---

## Adding a New Plugin

1. See `.meta/PLUGIN-GUIDE.md` for structure and patterns
2. Create `.meta/plugins/[plugin-name]/` with README, optional CONFIG, and `prompts/`
3. Add a one-line entry to the relevant table above
4. `/start-here` will detect it automatically on the next toolkit generation
