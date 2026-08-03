# Start Here — Phase Structure and Branching Logic

The toolkit generation process is adaptive. Phase 1 determines what questions are relevant in all subsequent phases. Do not ask questions that the context has already ruled out. Accept "I don't know yet" on any question and handle it as a deferred stub.

---

## Meta Library Map — What's Available to Pull From

Before generating anything, understand what the generator provides. Every file in `.meta/` is a potential input to generation. Read this map at the start of Phase 0 and use it throughout Phases 4 and 7.

### Always copied into every generated toolkit
| Resource | Source | Destination |
|---|---|---|
| `AI-BEHAVIOR-GUIDELINES.md` | `.meta/AI-BEHAVIOR-GUIDELINES.md` | toolkit root |
| Base permission layer | `.meta/settings.template.json` | `.claude/settings.json` (as starting point) |
| `/brief` skill | `.meta/base-skills/brief/` | `.claude/skills/brief/` |
| `/research` skill | `.meta/base-skills/research/` | `.claude/skills/research/` |
| `/solution-writer` skill | `.meta/base-skills/solution-writer/` | `.claude/skills/solution-writer/` |

### Conditionally included — copy based on discovery answers
| Resource | Source | Condition |
|---|---|---|
| Reference skills | `.meta/skills/[name]/` | User selects or skill matches workflow pattern |
| Plugins | `.meta/plugins/[name]/` | User selects or plugin matches workflow need |
| Output templates | `.meta/templates/[name]/` | User requests consistent output format |
| Research permission layer | `.meta/settings.research.json` | Toolkit needs web search or doc fetching |
| Developer permission layer | `.meta/settings.developer.json` | Toolkit involves writing/deploying code |
| Diagnostic permission layer | `.meta/settings.diagnostic.json` | Toolkit involves infrastructure inspection |

### Reference only — consulted during generation, not copied
| Resource | Use during generation |
|---|---|
| `ARCHITECTURE.md` | Understand the system being built; folder conventions |
| `SKILL-GUIDE.md` | Skill structure, A-J build sequence, platform decision matrix |
| `PLUGIN-GUIDE.md` | Plugin structure and patterns |
| `PHASES-GUIDE.md` | How to write PHASES.md for generated skills |
| `PROMPTS-GUIDE.md` | How to write PROMPTS.md for generated skills |
| `AGENTIC-PATTERNS.md` | Reusable agentic workflow patterns to recommend |
| `PROMPT-ENGINEERING.md` | Prompt design principles to bake into WORKFLOW.md |
| `DISCOVERY-PIPELINE.md` | Requirements extraction guidance for research/discovery toolkits |
| `MODEL-SELECTION.md` | Model guidance to include in CLAUDE.md if relevant |
| `SOLUTION-DOC-TEMPLATE.md` | Template structure for client-facing deliverables |
| `MEETING-NOTES-TEMPLATE.md` | Meeting notes format for `reference/meetings/` |
| `PERMISSIONS-TEMPLATE-README.md` | How to merge permission layers into `settings.json` |
| `TESTING-GUIDE.md` | Testing structure guidance when code involvement confirmed |
| `CLAUDE-CODE-SKILLS-REFERENCE.md` | Frontmatter fields and discovery rules for skills |

**Rule**: A generated toolkit should never be a blank skeleton. Every relevant `.meta/` resource should either be copied in, referenced in context docs, or explicitly deferred. If a resource is relevant and neither copied nor deferred, it was missed.

---

## Phase 0: Pre-Flight

Before starting, silently verify:
- Working directory contains the generator structure (`.meta/`, `.claude/skills/start-here/`)
- If not: hard stop — "This skill must be run from the ai-toolkit-accelerator directory."

**Git detach runs in Phase 8, not here.** Background subagents cannot request approval for destructive operations — rm -rf .git would fail silently in a forked context. The removal runs inline in the main conversation during Phase 8 cleanup. The generator runs in `auto` mode (`defaultMode: auto` in `.claude/settings.json`) so cleanup commands execute without prompting the user.

Announce in one line: "Starting toolkit generation. I'll ask a short set of discovery questions, then go deeper based on what you share."

---

## Phase 1: Discovery Intake

**Goal**: Surface the signals that determine which questions matter. Keep this tight — 4-5 questions maximum. Do not ask for the full workflow description yet.

Ask these questions, one at a time, waiting for each answer before continuing:

**Q1: Who is this toolkit for?**
- You personally (solo workflow)
- Your team (internal shared use)
- A client engagement (external delivery)
- Not sure yet

*Branches to:*
- Solo → lightweight path, Section B of SKILL-GUIDE sensibility, fewer confirmation gates
- Team/Client → full path with tracks, delivery platform, internal/client separation, handoff checklist

**Q2: What is the primary output — what does "done" look like for one complete run of this toolkit?**
Free text. A sentence or two. This anchors all phase and success-criteria questions later.

**Q3: Does this involve writing, reviewing, or deploying code?**
- Yes
- No
- Possibly / not sure yet

*Branches to:*
- Yes → architecture conventions checklist before phase design, test framework question, PR size guardrails
- No → skip all code-related questions
- Possibly → defer as stub (see Deferred Stubs section)

**Q4: Does this involve client-facing deliverables — documents, reports, presentations the client will receive?**
- Yes
- No
- Possibly / not sure yet

*Branches to:*
- Yes → delivery platform question, internal/client separation, solution doc pattern, handoff checklist
- No → skip delivery platform and separation questions
- Possibly → defer as stub

**Q5: Does the work span multiple independent workstreams or tracks?**
- Yes
- No
- Not sure yet

*Branches to:*
- Yes → ask for track names, generate per-track folder structure in docs/ and research/
- No → single docs/ and research/ at root
- Not sure → single structure with a note on how to expand to multi-track later

**Q5b (conditional — ask only when Q1 = "client engagement" or "team" AND Q3 = "yes" to code):**
**Is this an existing, already-built app — or greenfield?**
- Existing app (fixing bugs, adding features, extending)
- Greenfield (building from scratch)
- Not sure yet

*Branches to:*
- Existing app → agile-story workflow path: suggest Story Intake as Phase 1, Codebase Exploration as Phase 2; flag that APP-CONTEXT.md and ARCHITECTURE.md will be generated; surface agile-specific Phase 4 questions
- Greenfield with shared architecture/design → also generate APP-CONTEXT.md and ARCHITECTURE.md as empty templates: design decisions and architecture accumulate in them as meetings happen and docs are provided. The initial state is intentionally empty — value builds over time. Only generate if the user confirms they expect ongoing design discussions, architecture decisions, or accumulated context (not for one-off "help me with this code" interactions).
- Greenfield ad-hoc / no shared architecture → standard workflow path, no reference files
- Not sure → defer as stub

---

## Phase 2: Workflow Description

Now ask for the workflow description. Context from Phase 1 shapes the prompt — do not give a generic "describe your agent" prompt; reference what was shared.

Example prompt shape (adapt based on Phase 1 answers):
> "Based on what you've shared — [restate 2-3 key signals from Phase 1] — describe the workflow in more detail. What does the agent do step by step? What inputs does it start with? What does it produce?"

Accept file references: `file:path/to/description.txt`

After receiving the description:
1. Detect workflow type from the description: analysis / creation / processing / decision
2. Propose a phase structure (names and objectives only — not sub-steps yet)
3. Present recommendations with brief reasoning
4. Ask for confirmation or adjustments before proceeding

---

## Phase 3: Phase Design

For each confirmed phase, ask in sequence:

1. **Objective** — one sentence: what does this phase accomplish?
2. **Inputs** — what does this phase start with? (files, prior phase output, user input)
3. **Sub-steps** — what are the concrete actions? (comma-separated or numbered)
4. **Success signal** — how does the agent know this phase is done?
5. **Questions the agent should ask** — what does it need to clarify before running?

Keep this efficient. If the user answers Q1 in a way that makes Q3 or Q4 self-evident, skip them and confirm: "I'll infer the sub-steps from your objective — correct?"

---

## Phase 4: Follow-On Questions

Based on what emerged in Phases 1-3, go deeper on anything that determines what gets built. Use the Meta Library Map above — every conditional resource in that table corresponds to something to ask about here.

**The general pattern for each topic:**
1. Ask what you need to know to build it well
2. If the answer is clear: incorporate it into the generation plan
3. If the answer is "not sure / maybe / later": defer as stub — do not ask follow-up questions on it, do not block generation

**Topics to always cover in Phase 4** (adapt the question to context — don't read these as a script):

**Codebase Access Check (runs first, before technical questions, when Q3 = code involvement confirmed):**

Ask: "Is the codebase accessible right now? If so, how?"
- Local path on this machine
- GitHub URL
- Not accessible

If local path provided:
- Attempt `ls [path]` to verify Claude can read it
- If readable: proceed to codebase scan (below)
- If not readable: note it, continue with interview questions for tech details

If GitHub URL provided:
- Attempt WebFetch of the URL
- If readable: proceed to codebase scan (below)
- If not readable / auth required: note it, continue with interview questions

If not accessible: skip scan, continue with interview questions as normal

**Codebase scan (when accessible):**
- Read `package.json` (or equivalent: `pyproject.toml`, `Gemfile`, `pom.xml`) in root and sub-repos
- List top-level directory structure (`ls` to max depth 2)
- Read `jest.config.*`, `vitest.config.*`, `cypress.config.*` if present
- Read framework config files (`next.config.*`, `vite.config.*`, `tsconfig.json`) if present
- Extract: package manager, test framework, tech stack, coverage thresholds
- Use findings to skip or pre-answer the technical interview questions below

After scan: ask only the questions the scan could NOT answer.

**Accessibility scenarios to handle gracefully** (do not block on any of these — note and continue):
- Code on a client laptop with no local path available (VDI, locked environment) → skip scan, use interview questions
- Code in cloud infrastructure only (AWS, Azure) — no local repo → skip scan
- Microservices across multiple repos — user may only have access to some → scan what is accessible, note gaps
- Read-only access — user cannot clone locally, can only browse via web → offer GitHub URL path
- Monorepo — only certain packages are relevant → ask which package(s) before scanning
- Code accessible via VDI only — no direct path to Claude → skip scan, use interview questions

---

**Permissions / what the agent is allowed to do:**
Ask what the toolkit's agent will need to access. Map answers to the permission templates in `.meta/`:
- Needs to search the web, fetch documentation, call external APIs → include `settings.research.json`
- Needs to write/commit code, run tests, deploy to cloud → include `settings.developer.json`
- Needs to inspect infrastructure, run diagnostics, read cloud state → include `settings.diagnostic.json`
- Needs none of the above → base template only (`settings.template.json`)
- Not sure → defer as stub; generate with base template only and note in `.deferred/permissions.md`

The final `settings.json` is produced by merging the base layer with any additional layers. See `.meta/PERMISSIONS-TEMPLATE-README.md` for merge rules.

**Skills and plugins available:**
Scan `.meta/plugins/` and `.meta/skills/` before asking. List what exists. For each plugin/skill:
- Does the detected workflow type (from Phase 2) match this plugin's use case? → proactively offer it with a one-line description
- Does the user describe a need that maps to this capability? → offer it
- Not sure → skip; the user can add later

For consulting/agile developer toolkits specifically, proactively surface the Agile Dev Loop bundle:
- `ticket-parser` — extracts tasks, ACs, and checklist items from raw Jira/Linear/GitHub ticket text
- `standup-summary` — converts implementation notes into a 3–4 sentence spoken stand-up update
- `code-review-checklist` — generates a PR review checklist specific to the described change
- `pr-description-writer` — generates a structured PR description from branch/commit info

For consulting toolkits (client deliverables, analysis, communication), surface relevant plugins from:
- `meeting-notes-writer`, `status-report-writer`, `email-drafter` — communication
- `requirements-writer`, `loe-estimator`, `feedback-synthesizer` — consulting deliverables

**For each selected plugin, ask the invocation type** — one question per plugin, after the user confirms they want it:

> "How do you want to use [plugin-name]?
>   1. On-demand command — generates a `/[plugin-name]` slash command you invoke when you need it
>   2. Embedded in workflow — wired into a specific step in your WORKFLOW.md so it runs automatically at that point"

Record the invocation type for Phase 7. Default to on-demand if the user isn't sure.

**Output templates:**
Does the toolkit produce repeatable artifacts (reports, summaries, solution docs)? If yes → offer to include output templates from `.meta/templates/`. If not yet — defer.

**Agentic workflow patterns:**
Does the workflow involve multi-agent orchestration, iterative loops, TDD, or backlog generation? If yes → reference the relevant pattern from `.meta/AGENTIC-PATTERNS.md` in the generated WORKFLOW.md so the user has it as a starting point.

**Reference material for WORKFLOW.md:**
Based on what the toolkit does, decide which `.meta/` reference docs to surface in the generated toolkit's WORKFLOW.md or CLAUDE.md:
- Discovery/research heavy → pull from `DISCOVERY-PIPELINE.md`
- Client deliverables → reference `SOLUTION-DOC-TEMPLATE.md`
- Model selection matters → include relevant section from `MODEL-SELECTION.md`
- Prompt engineering is core to the workflow → reference `PROMPT-ENGINEERING.md`

**For existing-app / agile workflows (when Q5b = "Existing app"):**
- Story intake structure: does the team use Jira? What fields matter (tasks, ACs, checklist, story points)?
- Branch and PR conventions: what is the branching strategy? PR to which branch? Reviewer requirements?
- Testing requirements: what tier of tests is expected?
  - Unit tests: most common starting point — ask about framework (Jest, pytest, etc.) and coverage threshold
  - Integration tests: ask if the team writes them and in what scenarios
  - E2E tests: ask if the team uses them (Playwright, Cypress, etc.) — often deferred
  - Defer any tier not yet confirmed as a stub, but surface all three tiers so none are silently skipped
- Pipeline/verification: is there a dev or staging pipeline the developer can verify against before merge?

**Path-scoped rules (for code toolkits — Q3 = yes):**

Ask after the codebase access check, once the tech stack is known:

```
"Does your codebase have distinct layers with their own conventions —
 for example, a frontend layer, API layer, testing setup, or database access?

 If yes: I'll generate a starter rule file per layer in .claude/rules/. These
 only load when Claude touches files in that layer — zero token cost otherwise.
 You populate them as you explore the codebase.

 1. Yes — list the layers (e.g. 'frontend, api, testing')
 2. Not sure yet — generate one catch-all conventions.md I can split later
 3. No distinct layers / not applicable"
```

Record confirmed layers for Phase 7. If "not sure yet": generate single `conventions.md`. If "not applicable": skip rules entirely.

**Code workflow type (for code toolkits — Q3 = yes):**

This covers how Claude handles implementation and testing work. Only ask for toolkits that involve writing, reviewing, or deploying code — these modes map to code workflows specifically, not to conversational or consulting work.

Ask once for implementation, then separately for testing if testing was confirmed. They can be the same or different.

```
"How do you want Claude to work with you on implementation?
  1. Mentorship — you write code, Claude coaches, explains tradeoffs, flags multi-file impacts
  2. Pair Programmer — Claude generates and explains patterns as you co-create
  3. Supervised Delegation — Claude executes, pauses at every key decision for your approval
  4. Autonomous — Claude executes end-to-end, you review at the finish
  5. Mixed — set a default per phase, switch on request"
```

Then, if testing was confirmed (any tier):
```
"For tests specifically — same mode, or different?
  1. Same as implementation
  2. Mentorship — you write tests, Claude coaches on structure and coverage
  3. Pair Programmer — Claude writes tests and explains the pattern (why this mock, why this assertion)
  4. Supervised Delegation — Claude writes tests, pauses at structural decisions
  5. Autonomous — Claude writes all tests, you review at the end"
```

Record both in WORKFLOW.md under an "Interaction Types" section — one entry for implementation, one for testing, with activation phrases and how to switch mid-session. See `.meta/AGENTIC-PATTERNS.md` — "Interaction Types" section for full definitions.

**Other topics that may surface** (illustrations, not a checklist):
- How work is structured across the engagement (tracks, ownership)
- Conventions the team follows (code, naming, review gates)
- Integrations and tools already in play
- What the success signal is for the engagement overall

Read the signals from Phase 1 and ask only what's relevant. A solo personal workflow does not need delivery platform or permissions questions beyond the base template. A pure documentation workflow does not need architecture convention questions. When in doubt: one short framing question to find out, then decide whether to go deeper or defer.

---

## Phase 5: Surface Unknowns

Before generating, do a single pass over all "possibly / not sure yet" answers from Phases 1-4.

For each unknown, confirm with the user:
> "[Topic X] was marked as not yet known. I'll create a deferred stub for it — a placeholder that explains what to build and what questions to answer when you're ready to expand it. Is that right, or do you want to answer now?"

This keeps the conversation moving without forcing premature decisions.

---

## Phase 6: Final Confirmation

Present the full structure summary (see PROMPTS.md for format). Include a "Deferred Stubs" section listing any topics being parked for later.

Ask: "Ready to generate?" Allow modifications before proceeding.

**After the user confirms — before Phase 7 starts — suggest a folder rename:**

Derive a kebab-case folder name from the toolkit name confirmed during discovery. Examples:
- "Edgar's Slalom Workflow Toolkit" → `slalom-workflow-toolkit`
- "Client Research Assistant" → `client-research-assistant`
- "AP Invoice Monitoring Toolkit" → `ap-invoice-monitoring`

Check the current folder name with `pwd`. If it already looks intentional (not a default clone name like `ai-toolkit-accelerator`, `ai-toolkit-accelerator-copy`, `meta-toolkit`, or similar generator names), skip this step.

If it looks like a default or placeholder name, ask:
> "This folder is currently named `[current-name]`. Based on your toolkit, I'd suggest `[derived-name]`. Want me to rename it now before generation starts?"

- If yes → run `mv "[current-path]" "[parent-path]/[derived-name]"` — the session follows the rename automatically, no restart needed. Confirm the rename succeeded with `pwd`.
- If no → proceed with the current name.
- If the user suggests their own name → use that instead.

**Important**: Do this rename before any files are written. Once Phase 7 starts generating files, do not rename mid-generation.

**Cloud-sync path detection — run before any rename:**

Check if `pwd` contains any of the following:
- `~/Library/CloudStorage/`
- `~/OneDrive/`
- `~/Google Drive/`
- `~/Dropbox/`
- `~/Box/`

If a cloud-sync path is detected, warn the user before proceeding:
> "⚠️ This folder appears to be inside a cloud-synced directory ([detected path]). `mv` will rename it correctly — OneDrive and other providers use inode-based tracking, so `mv` is a true rename, not a delete+create. However, OneDrive needs a moment to sync the rename to the server via a PATCH request. If your OAuth token expires before that PATCH completes, OneDrive may re-materialize the old folder name on next login.
>
> Recommendation: after generation completes, wait for the OneDrive sync icon to clear before closing this terminal session — then open a fresh Claude Code session in the new folder path."

Do not rename silently in a cloud-sync path. Always surface this warning and let the user decide. Options:
1. Rename and wait for sync to complete before closing the session (recommended)
2. Skip the rename and continue with the current name
3. Rename after generation, outside of Claude, once the session is closed

**Never use `cp -r + rm -rf` on cloud-synced paths** — this creates new inodes, which sync clients interpret as delete+re-upload rather than a rename. It is actively harmful on OneDrive and other providers.

**Why `mv` is safe — confirmed by research**: `mv` executes a `rename(2)` syscall that preserves inodes. OneDrive's local database updates the folder name in-place (same item ID, same inode, same server-side DriveItem ID) and propagates the rename to the server as an atomic PATCH. The "old folder reappears" issue occurs only when the OAuth token expires while the sync PATCH is still queued — not from `mv` itself. Waiting for sync to complete before closing the session prevents this.

**Exception**: Google Drive in streaming mode (virtual folders) — folder renames from terminal are unreliable. If the user is in `~/Library/CloudStorage/` with Google Drive streaming, recommend renaming via Finder instead.

**Why this is safe on local (non-cloud-synced) paths — tested and confirmed**: The shell working directory updates automatically to the new path. File reads, file writes, and permission enforcement all continue working without interruption. The session follows the rename because macOS resolves the inode, not the path.

---

## Phase 7: Generate

Create all files. Reference PROMPTS.md for progress messaging format. Use the Meta Library Map to verify nothing was missed before closing.

**CLAUDE.md discipline — applies to every generated toolkit:**
Generated CLAUDE.md must stay under 200 lines. It is injected at every session start — everything in it pays a token cost every session. Keep it lean:
- Include: toolkit purpose, key file locations, skills/plugins available, deferred stubs, provenance
- Exclude: layer-specific conventions (→ rules files), phase instructions (→ WORKFLOW.md), architecture patterns (→ reference/ files)
- HTML comments are free (stripped before injection) — use for maintainer notes

**Always generated:**
1. Directory structure (docs/, research/, reference/meetings/, .claude/skills/)
2. CLAUDE.md (session guide with dynamic provenance paragraph — keep under 200 lines per discipline above)
3. README.md
4. GETTING_STARTED.md — day-one operational guide (distinct from README which explains what the toolkit is). Include: run /brief first; how to invoke /research and /solution-writer; where WORKFLOW.md and CONFIG.md live; how to expand a deferred stub (describe the need in a new session); note that to add new skills later, describe the need in a session and Claude will build it following the pattern of existing skills; one-line note about auto-memory (~/.claude/projects/.../MEMORY.md)
5. workflow/WORKFLOW.md — embed relevant agentic patterns, prompt engineering principles, and discovery pipeline guidance as appropriate for this toolkit's workflow type
6. workflow/CONFIG.md
7. AI-BEHAVIOR-GUIDELINES.md (copy from `.meta/AI-BEHAVIOR-GUIDELINES.md`)
8. .claude/settings.json — **always created.** Start with `settings.template.json` as the base. Merge in any additional permission layers confirmed in Phase 4 (research, developer, diagnostic). If none were confirmed, the file still gets created with the base layer only. See `.meta/PERMISSIONS-TEMPLATE-README.md` for merge rules.
8b. .claude/PERMISSIONS-GUIDE.md — always generated alongside settings.json. Documents: which permission layers were included and why, what each layer allows, and which layer to edit when adding new permissions. One paragraph per included layer.
8c. .gitignore — always generated. Minimum contents: `settings.local.json` and `.DS_Store`. Add framework-specific entries if tech stack was confirmed (node_modules/, __pycache__/, .env, dist/, build/, etc.).

**Base skills — always copied from `.meta/base-skills/`:**
9. .claude/skills/brief/
10. .claude/skills/research/
11. .claude/skills/solution-writer/

**Starter documents — empty templates with structure:**
12. docs/ACTION-ITEMS.md
13. docs/PROJECT-CONTEXT.md
14. reference/meetings/MEETING-NOTES-SUMMARY.md — use `.meta/MEETING-NOTES-TEMPLATE.md` as the format reference

**Conditional — only if selected or confirmed during Phase 4:**
15. `.claude/rules/` — generate based on rules answer from Phase 4:
    - **Layers confirmed**: generate one `.claude/rules/[layer].md` per layer. Each file gets `paths:` frontmatter matching that layer's directories, section headers (Component Structure, Conventions, Patterns, etc.), and a header comment: "Populate as you explore — add conventions here when you discover patterns worth remembering." Do not pre-fill with assumptions.
    - **Not sure yet**: generate a single `.claude/rules/conventions.md` with broad paths (`["src/**", "**/*.ts", "**/*.js"]` or equivalent) and a note explaining how to split into layer files when layers become clear.
    - **Not applicable**: skip entirely.
    - Example path globs by layer type: frontend → `["src/components/**", "src/pages/**"]`; api → `["src/api/**", "server/**"]`; testing → `["**/*.test.*", "**/*.spec.*", "tests/**"]`; database → `["src/db/**", "migrations/**"]`
16. Skills from `.meta/skills/` → copy selected ones to `skills/` at toolkit root
17. Plugins from `.meta/plugins/` → copy selected ones to `plugins/` at toolkit root. For each plugin, generate based on the invocation type confirmed in Phase 4:
    - **On-demand**: copy plugin folder to `plugins/[name]/` AND generate a skill wrapper at `.claude/skills/[name]/SKILL.md`. The skill frontmatter must include a `description:` that triggers on the use case (e.g. "Use when you have a ticket to parse"). The skill body: load the plugin prompt, ask the user for required variables, run it.
    - **Workflow-embedded**: copy plugin folder to `plugins/[name]/` AND add a reference at the relevant step in WORKFLOW.md: "At this step, load `plugins/[name]/prompts/[prompt].prompt.md`, fill in the variables, and run." Do not generate a skill wrapper.
    - If invocation type was not confirmed: default to on-demand.
18. Templates from `.meta/templates/` → copy selected ones to `templates/` at toolkit root
19. Testing structure — if code involvement confirmed, use `.meta/TESTING-GUIDE.md` as reference
20. Validation hooks — if requested
21. `reference/[codebase-name]/APP-CONTEXT.md` — if toolkit targets an existing codebase (Q5b = "Existing app"): create as an empty template with sections: Feature Locations, Key Components, Route Map, Notes. Include a header comment: "Updated during stories as new areas are explored — load this before codebase work."
22. `reference/[codebase-name]/ARCHITECTURE.md` — same condition as above: create as empty template with sections: State Management, Auth Pattern, API Communication, Data Flow, Team Conventions. Include header comment: "Updated when a pattern is understood deeply enough to be worth recording."

**Deferred:**
23. `.deferred/[topic].md` for any "not sure yet" answers — the stub's Reference section should point to the generated toolkit's own docs (workflow/WORKFLOW.md, CLAUDE.md) not to `.meta/` guides, which are deleted after generation

**Before closing Phase 7 — verify against Meta Library Map:**
- Every conditional resource in the map is either included, explicitly skipped, or deferred
- `.claude/settings.json` exists (always — even if only the base layer was needed)
- WORKFLOW.md references any relevant patterns from `AGENTIC-PATTERNS.md` or `PROMPT-ENGINEERING.md`
- CLAUDE.md provenance section lists everything active in this toolkit
- CLAUDE.md is under 200 lines — if over, move layer-specific content to `.claude/rules/` files

---

## Phase 8: Clean Up and Close

**Step 1 — Git detach (inline, main conversation):**

Run directly — do not use a subagent. The generator runs in `auto` mode so this executes without prompting.

```bash
rm -rf .git
```

Verify with `ls -la .git`:
- If `.git` is gone: success — include this in the completion message: "Git history and remote connection removed. This toolkit is clean — run `git init` when you're ready to start your own repository."
- If `.git` still exists: include this warning instead: "⚠️ Git detach incomplete — .git still exists. Run `rm -rf .git` manually, then `git init` to start fresh."

**Step 2 — Delete scaffolding:**

**Important**: Always use relative paths with `rm -rf`. Absolute paths with `rm -rf` are blocked by Claude Code's safety layer regardless of `settings.json`. All commands below use relative paths from the project root — confirm `pwd` is the toolkit root before running.

```bash
rm -rf .claude/skills/start-here/
rm -rf .meta/
rm -f START_HERE.md
rm -f DESIGN_PHILOSOPHY.md
```

The generated toolkit's `.claude/skills/` now contains only the base skills copied during generation (brief, research, solution-writer). The `.meta/` deletion does not affect them — they were already copied to their destination.

**Step 3 — Validate and report:**
Verify all required files exist. Report completion with a summary of what was generated and what was deferred. Include the git detach note (success or warning) as determined in Step 1.

---

## Deferred Stubs Protocol

Any time a user answers "not sure," "maybe," "possibly," or "later" — on *any* topic — generate a stub. This applies universally: no topic is too small or too large to defer. The stub is always the same structure, regardless of what the topic is.

Create `.deferred/[topic-name].md`:

```markdown
# Deferred: [Topic Name]

**Status**: Not yet implemented — expand when ready

## What this would add

[2-3 sentences: what would be built if this were confirmed, and why it matters]

## Questions to answer first

- [The question that was deferred]
- [Any sub-questions that would naturally follow from the answer]
- [Continue until the shape of what needs to be built would be clear]

## How to expand

When ready, describe the need in a new session. The process will:
1. Walk through the questions above
2. Run `/research` for current patterns, examples, and best practices if useful
3. Generate the component and integrate it into the existing toolkit

## Reference

- See `workflow/WORKFLOW.md` for how this toolkit is structured and how phases connect
- See `CLAUDE.md` for the full list of what was generated and what remains deferred
- To extend this toolkit in any way (new skill, plugin, rule file, settings update, workflow phase, or anything else): describe the need in a new session. Claude will build it based on the existing toolkit structure and its training. No guide file is needed.
```

Keep stub filenames short and descriptive: `testing.md`, `delivery-platform.md`, `track-structure.md`, `integrations.md` — whatever names the topic clearly.

Stubs are listed in the CLAUDE.md "About This Toolkit" section so they surface at the start of every session.

---

## Handling Expansion Requests (Post-Generation)

If a user returns with a deferred topic — "we do have unit tests now, here's the framework" — the pattern is:

1. Read the relevant `.deferred/[topic].md` stub
2. Run the same discovery questions listed in the stub
3. If patterns/best practices/examples would help: invoke `/research` with a focused query before generating
4. Generate the component
5. Integrate into the existing toolkit (update WORKFLOW.md, CLAUDE.md provenance section, any affected skills)
6. Delete the stub once complete

This is the same process whether the user is starting immediately after generation or returning to a deferred topic in a later session.

---

---

## After Generation — Start a New Session

Once Phase 8 completes and the toolkit is ready, **close this session and open a new one** in the generated toolkit folder.

**Why this is required**: Claude Code's skill registry is anchored to the folder path at session start. If the folder was renamed during Phase 6, the current session cannot discover skills by their `/skill-name` commands — even though file access works correctly. Starting a fresh session in the renamed folder re-anchors the registry, making `/brief`, `/research`, `/solution-writer`, and any custom skills fully available.

The completion message should include:
> "Open a new Claude Code session in this folder to start using your toolkit. Skills are not available in the generation session after a folder rename."

---

