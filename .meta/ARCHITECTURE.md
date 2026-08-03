# Meta-Toolkit Architecture

This document explains how the AI Toolkit Generator works as a **scaffolding system**.

---

## Core Concept

This is NOT a template you fill in manually.
This IS a **generator** that builds custom toolkits through an adaptive discovery conversation.

### The Transformation

**Before `/start-here`**:
```
ai-toolkit-accelerator/          # Meta-toolkit (scaffolding)
├── README.md                    # Explains meta-toolkit
├── DESIGN_PHILOSOPHY.md         # Design rationale — persists after generation
├── .claude/skills/start-here/   # Only executable skill on the generator
└── .meta/                       # All reference material + source templates
    ├── base-skills/             # Copied into every generated toolkit's .claude/skills/
    │   ├── brief/               # → /brief
    │   ├── research/            # → /research
    │   └── solution-writer/     # → /solution-writer
    ├── plugins/                 # Accumulated reusable capabilities
    ├── skills/                  # Reusable workflow patterns (iterative-processing starter included)
    └── templates/               # Accumulated output format templates
```

**After `/start-here`**:
```
my-custom-toolkit/               # YOUR toolkit
├── CLAUDE.md                    # Session guide with provenance summary
├── README.md                    # Explains YOUR toolkit
├── workflow/
│   ├── WORKFLOW.md              # YOUR phases
│   └── CONFIG.md                # YOUR settings
├── docs/
│   ├── ACTION-ITEMS.md          # Active tasks and blockers
│   └── PROJECT-CONTEXT.md       # Client context
├── reference/meetings/
│   └── MEETING-NOTES-SUMMARY.md
├── .claude/skills/
│   ├── brief/                   # /brief — session orientation
│   ├── research/                # /research — technical research
│   └── solution-writer/         # /solution-writer — planning + client docs
├── plugins/                     # Copied from .meta/plugins/ if selected
├── skills/                      # Copied from .meta/skills/ if selected
├── templates/                   # Copied from .meta/templates/ if requested
└── .deferred/                   # Stubs for topics not yet decided
```

**What happened**:
1. `/start-here` ran a discovery conversation — branching on context, accepting unknowns
2. Generated custom CLAUDE.md, workflow, config, README, and session scaffolding
3. Created deferred stubs for any "not yet known" answers
4. **Deleted itself** (.meta/, start-here skill gone)
5. Result: Clean, expandable toolkit ready for immediate use

---

## Why This Architecture?

### Problem with V2.0 (Template Approach)

User copies skeleton → manually edits WORKFLOW.template.md → manually edits CONFIG.template.md → manually removes unused components → still has "how to build a toolkit" docs mixed with actual toolkit.

**Issues**:
- Manual work to transform template to actual toolkit
- Starter documentation remains (confusing)
- Easy to miss steps
- Not self-contained

### Solution: Meta-Toolkit (Generator Approach)

User copies accelerator → runs `/start-here` → adaptive discovery conversation → **toolkit generates itself** → scaffolding automatically deleted → ready to use.

**Benefits**:
- ✅ Automated transformation
- ✅ Starter docs disappear after generation
- ✅ Only selected components remain
- ✅ Clean, professional result
- ✅ No manual template filling

---

## Component Architecture

### Plugins (Capabilities)

**What**: Reusable, prompt-based capabilities you can plug into toolkits

**Invocation types** — set per plugin at generation time:
- **On-demand**: generates a `.claude/skills/[name]/SKILL.md` wrapper so the plugin becomes a `/command` the user invokes when needed. Best for ad-hoc tasks.
- **Workflow-embedded**: adds a reference at the relevant step in WORKFLOW.md. No skill wrapper. Best for recurring tasks that happen at a predictable point in the workflow.

The plugin folder structure is identical either way — only the generated wrapper differs.

**Examples**:
- email-composer: Write emails in your style
- invoice-processor: Extract data from invoices
- code-analyzer: Parse and analyze code
- decision-framework: Structured decision-making

**Structure**:
```
plugins/email-composer/
├── README.md                 # What it does, how to use
├── CONFIG.md                 # Configuration options
├── processor.py              # (Optional) Processing logic
└── prompts/                  # AI prompt templates
    ├── draft.prompt.md
    └── refine.prompt.md
```

**How it works**:
- User selects plugins during generation
- Unselected plugins are deleted
- Selected plugins remain, ready to use
- Each plugin is self-contained

### Skills (Workflows)

**What**: Reusable workflow patterns you can combine

**Examples**:
- analyze: Systematic analysis pattern
- extract: Information extraction pattern
- synthesize: Combination pattern
- generate: Content generation pattern

**Structure**:
```
skills/analyze/
├── README.md                 # What it does
├── PHASES.md                 # Phase structure
└── prompts/                  # AI prompt templates
    ├── phase1.prompt.md
    ├── phase2.prompt.md
    └── phase3.prompt.md
```

**How it works**:
- User selects skills during generation
- Skills define phase patterns
- User's workflow can reference skills
- Provides proven patterns

### Templates (Outputs)

**What**: Reusable output formats

**Examples**:
- email.template.md
- report.template.md
- analysis.template.md
- summary.template.md

**Structure**:
```
templates/email.template.md
- Sections defined
- Instructions for AI
- Examples included
```

**How it works**:
- Bootstrap can copy selected templates
- User's workflow references templates
- Provides consistency

---

## Generation Process

### Step-by-Step

1. **Discovery Intake** (Phase 1 of `/start-here`)
   - Audience: solo / team / client
   - What "done" looks like
   - Code involvement
   - Client deliverables
   - Multi-track structure

2. **Workflow Description + Analysis** (Phase 2)
   - Natural language description
   - Workflow type detection
   - Phase structure proposal

3. **Phase Design** (Phase 3)
   - Per-phase: objective, inputs, sub-steps, success signal

4. **Conditional Deep Dives** (Phase 4)
   - Architecture conventions (if code)
   - Delivery platform (if client deliverables)
   - Track structure (if multi-track)
   - Skills and plugins

5. **Surface Unknowns** (Phase 5)
   - Confirm deferred stubs for all "not yet known" answers

6. **Generate** (Phase 7)
   - CLAUDE.md, WORKFLOW.md, CONFIG.md, session scaffolding
   - Selected skills, plugins, templates
   - Deferred stubs in `.deferred/`

7. **Clean Up** (Phase 8)
   - Delete `.meta/`, `start-here` skill, scaffolding artifacts
   - Validate all required files exist

8. **Result**
   - Clean, custom toolkit
   - Deferred stubs for anything not yet decided
   - Ready to use immediately — expandable as work evolves

---

## Extension Points

### Adding New Plugins

1. Create `.meta/plugins/[plugin-name]/`
2. Add `README.md` explaining it
3. Add `CONFIG.md` for settings
4. Add any processor scripts
5. Add prompt templates
6. `/start-here` will automatically detect and offer it on the next generation

### Adding New Skills

1. Create `.meta/skills/[skill-name]/`
2. Add `README.md` explaining pattern
3. Add `PHASES.md` defining structure
4. Add prompt templates
5. `/start-here` will automatically detect and offer it on the next generation

### Customizing Generation

Edit `.claude/skills/start-here/PHASES.md`:
- Add new discovery branches
- Add new conditional deep-dive blocks
- Adjust deferred stub content
- Change the generation order

---

## Design Decisions

### Why Adaptive Generator vs. Fixed Wizard?

**Adaptive generator pros**:
- Branches on context — different use cases get different questions
- Accepts unknowns gracefully — deferred stubs rather than forced answers
- Produces a living toolkit — expandable as the engagement evolves
- Quality scales with complexity — simple workflows stay simple

**Fixed wizard cons (why bootstrap.py was removed)**:
- Same linear question order regardless of context
- Forces answers to questions that don't yet apply
- No branching — every toolkit gets the same shape
- Premature decisions baked in without the reasoning that should drive them

### Why Delete Starter Files?

After generation, user doesn't need:
- How to build a toolkit (they already did)
- Bootstrap script (already ran)
- Meta-documentation (not relevant to their toolkit)

Keeping them creates confusion: "Is this about MY toolkit or about building toolkits?"

Deleting creates clarity: Everything remaining is about THEIR toolkit.

### Why Plugins + Skills?

**Plugins** = concrete capabilities (email, invoices, code)  
**Skills** = abstract patterns (analyze, extract, generate)

Different levels of abstraction:
- Plugins: Domain-specific
- Skills: Domain-agnostic patterns

User might need:
- Just plugins (email-composer)
- Just skills (analyze pattern for custom use case)
- Both (code-analyzer plugin + analyze skill pattern)

### Three Skill Locations — Why Each Exists

**`.meta/skills/`** = Reference patterns (non-executable)
- Reusable workflow patterns accumulated across engagements
- Documentation and structure only — not invokable as commands
- Copied into a generated toolkit's `skills/` at root when selected
- Examples: multi-step-analysis, iterative-processing

**`.meta/base-skills/`** = Toolkit operational skills (source templates)
- Skills that belong in every generated toolkit: `/brief`, `/research`, `/solution-writer`
- Not useful on the generator itself — they read project files that don't exist here
- Copied into a generated toolkit's `.claude/skills/` automatically at generation time
- After copying, they become live `/skill-name` commands in the generated toolkit

**`.claude/skills/`** = Executable commands (live, invokable now)
- Claude Code scans this folder and makes each subfolder a `/skill-name` command
- On the generator: only `/start-here` lives here
- On a generated toolkit: `/brief`, `/research`, `/solution-writer`, and any others selected

**Discovery Rule**: Claude Code only finds skills in `.claude/skills/` (or `~/.claude/skills/` for personal). Skills in `.meta/` are invisible to Claude Code until copied.
- Keeps reference docs clean from execution requirements

---

## How Generation Works

Files are generated inline by Claude following the phase-by-phase instructions in `.claude/skills/start-here/PHASES.md`. There is no script — the generator is the conversation. Phase 7 defines what gets created, in what order, and with what content. Phase 8 deletes scaffolding.

Each generated file is written directly into the toolkit folder during the conversation. Discovery answers from Phases 1-4 determine which conditional files are included and what content goes into CLAUDE.md, WORKFLOW.md, and CONFIG.md.

---

## Comparison to Other Tools

### vs. create-react-app

**Similarity**: Bootstrap generates project structure  
**Difference**: This generates AI workflows, not code projects

### vs. Yeoman

**Similarity**: Generator pattern  
**Difference**: AI-specific, not general-purpose

### vs. Cookiecutter

**Similarity**: Template substitution  
**Difference**: This is interactive wizard + logic, not just file templates

---

## Future Enhancements

Potential additions:

1. **Plugin Marketplace**: Share/discover community plugins
2. **Skill Library**: More pre-built workflow patterns
3. **Multi-Toolkit Projects**: Compose multiple toolkits
4. **Version Control**: Track toolkit evolution
5. **Testing Framework**: Validate toolkit outputs
6. **Interactive Mode**: Real-time toolkit refinement

---

## For Developers

### Contributing Plugins

1. Study existing plugins
2. Follow plugin structure
3. Document thoroughly
4. Test with `/start-here` generation
5. Submit PR

### Contributing Skills

1. Study existing skills
2. Define clear phase pattern
3. Provide prompt templates
4. Document use cases
5. Submit PR

### Improving Bootstrap

1. Add questions
2. Improve generation logic
3. Better error handling
4. More validation
5. Enhanced UX

---

## Before You Start (Architecture Conventions Checklist)

Before the first spec or agent run on any code-based engagement, define these conventions in your context docs. If you do not define how you want your code written and tested, the AI will find the shortest path from A to B — usually no tests and one single massive file.

- [ ] Layer separation (e.g., View/Component layer, Service/Business Logic layer, Data Access layer)
- [ ] Max component/file length (e.g., no component over 200 lines)
- [ ] Testing requirements (framework, coverage threshold, naming conventions)
- [ ] How tests should be organized (unit, integration, E2E locations)
- [ ] PR size guardrails (e.g., stop at 20 files changed)
- [ ] Story/epic size guardrails (e.g., break out anything over 8 points)

**Cautionary principle**: Without defined conventions, AI finds the shortest path — resulting in 1,000-plus line React components, single-digit test coverage, and tests that aren't running in the pipeline. All of it preventable by defining architecture conventions before generation begins.

---

## Engagement Folder Structure

The following structure reflects what works in practice for an AI-assisted engagement toolkit. Bootstrap generates the core skeleton; additional folders emerge as the engagement progresses.

### Default Generated Structure

```
toolkit-root/
  CLAUDE.md                         # Session guide — always present, updated continuously
  .gitignore                        # Always: settings.local.json, .DS_Store at minimum
  .gitignore                        # Always: settings.local.json, .DS_Store at minimum
  .claude/
    settings.json                   # Merged from permission templates
    settings.local.json             # Machine-specific paths only — never committed
    PERMISSIONS-GUIDE.md            # Documents which permission layers were merged and why
    skills/
      brief/                        # Session initialization skill — always included
        SKILL.md
        prompt.md
  docs/
    ACTION-ITEMS.md                 # Active blockers, tasks, priorities (internal)
    PROJECT-CONTEXT.md              # Client context, stakeholders, risks
  reference/
    meetings/
      MEETING-NOTES-SUMMARY.md      # All meetings consolidated in one file
  research/                         # Raw external findings only — easily deletable
```

### Folders That Emerge Mid-Engagement

These are not generated at toolkit creation time. They get created when the work calls for them:

```
  docs/
    [track-name]/                   # One subfolder per workstream when scope expands
      [track-specific docs]
  research/
    [track-name]/                   # Mirrors docs/ structure for that track's findings
  reference/
    jira/                           # Or equivalent ticket system
  solutions/                        # Client-facing deliverables — created when needed
    [use-case-name].md              # One file per deliverable
  docs/[track-name]/
    solution-planning/              # Internal pre-work per deliverable — created when needed
```

---

## Multi-Track Engagement Pattern

When an engagement pivots or expands scope, use subfolders within `docs/` and `research/` named for each track:

```
docs/
  ACTION-ITEMS.md                   # Cross-cutting, stays at root
  PROJECT-CONTEXT.md                # Cross-cutting, stays at root
  ap_invoice_monitoring/            # Track 1
    TRACK_PLAN.md
    solution-planning/
    solutions/
  finance_use_cases/                # Track 2
    TRACK_PLAN.md
    solution-planning/
    solutions/

research/
  ap_invoice_monitoring/            # Mirrors docs/ track structure
  finance_use_cases/
```

**Rule**: Cross-cutting files (ACTION-ITEMS, PROJECT-CONTEXT) always stay at the root of `docs/`. Track-specific files always go in their subfolder.

---

## Client vs Internal Content Separation

Every toolkit involves content at different confidentiality levels. The folder structure enforces this:

| Content type | Location | Shared with client? |
|---|---|---|
| Raw research findings | `research/` | No |
| Internal planning notes | `docs/[track]/solution-planning/` | No |
| Active tasks and blockers | `docs/ACTION-ITEMS.md` | No |
| Client-facing deliverables | `docs/[track]/solutions/` | Yes |
| Meeting notes | `reference/meetings/` | No (unless extracted) |

Within solution docs, internal-only sections are flagged:

```markdown
> ⚠️ Internal only - remove before client delivery
```

**The delivery flow**: `research/` → `solution-planning/` → `solutions/` (client-ready)

---

## The `.archive/` Convention

`.archive/` is a deliberate graduation step, not a dumping ground.

**What belongs in `.archive/`**:
- Working documents that are done and no longer actively referenced
- Planning docs whose corresponding deliverable is finalized
- Session artifacts and implementation summaries that have historical value
- Superseded drafts where the current version is in its proper location

**What does not belong in `.archive/`**:
- Files that are just unused but might become active again (leave them in place)
- Files you are unsure about (if unsure, ask)
- Duplicates of files that are already current elsewhere

**The `solution-planning/` graduation rule**: Once a solution doc in `solutions/` is marked client-ready, the corresponding planning doc in `solution-planning/` moves to `.archive/[track-name]/`. The planning work is done; the deliverable is the record.

**Structure**:
```
.archive/
  [track-name]/                     # Graduated planning docs
  old-dev-notes/            # Session artifacts from toolkit setup
  [other-category]/
```

---

## Context Management Patterns

Every generated toolkit should be designed with session efficiency in mind. These three patterns work together.

### CLAUDE.md 200-line discipline

CLAUDE.md is injected as a user message at every session start — it pays a token cost every session. Beyond ~200 lines, adherence degrades.

**What belongs in CLAUDE.md** (session-critical, always needed):
- Toolkit name and one-line purpose
- Key file locations table
- Skills and plugins available
- Deferred stubs list
- Provenance summary

**What does not belong in CLAUDE.md**:
- Layer-specific code conventions → `.claude/rules/[layer].md`
- Phase-specific instructions → `workflow/WORKFLOW.md`
- Architecture patterns → `reference/[codebase]/ARCHITECTURE.md`
- Codebase navigational map → `reference/[codebase]/APP-CONTEXT.md`

HTML comments in CLAUDE.md are free — stripped before injection, don't cost tokens. Use them for maintainer notes.

### Path-scoped rules (.claude/rules/)

Rules files auto-load when Claude touches a file matching the path glob. Zero token cost when the path doesn't match — the opposite of CLAUDE.md which always loads.

This is the correct overflow valve for layer-specific conventions. For a typical web app:

```
.claude/rules/
  frontend.md     paths: ["src/components/**", "src/pages/**"]
  api.md          paths: ["src/api/**", "server/**"]
  testing.md      paths: ["**/*.test.*", "**/*.spec.*", "tests/**"]
  database.md     paths: ["src/db/**", "migrations/**"]
```

Categories emerge from the codebase's own layers — don't pre-decide them. Start with one `conventions.md` if layers aren't clear yet; split as the codebase is explored.

Rule files generated by `/start-here` are starters — clearly marked with section headers and a note to populate as the codebase is explored, not pre-filled with assumptions.

### Auto-memory (Claude Code CLI)

Claude Code automatically writes `~/.claude/projects/<project>/memory/MEMORY.md`. First 200 lines load every session; topic files read on demand. This is free automatic context accumulation.

Use it intentionally: if Claude derives something in a session that would be worth knowing next time, write it to the memory file before the session closes. The `/brief` skill notes this as available — it does not manage the file itself.

---

## File Naming Convention

All files in generated toolkits follow this standard:

| File type | Convention | Examples |
|---|---|---|
| Regular files | `kebab-case.md` | `feature-notes.md`, `api-design.md` |
| Landmark aggregate files (single authoritative references) | `ALL-CAPS-KEBAB.md` | `PROJECT-CONTEXT.md`, `ACTION-ITEMS.md`, `MEETING-NOTES-SUMMARY.md`, `APP-CONTEXT.md`, `ARCHITECTURE.md` |
| Per-item files named after external IDs | Match the external system | `IDEA-123.md`, `PROJ-456.md` |
| Generator meta files | Stay ALL-CAPS (they are landmark files in the generator sense) | `PHASES.md`, `SKILL.md`, `PROMPTS.md` |

**Rule**: Landmark files are the single authoritative reference for their domain — there is exactly one per toolkit. Regular files are per-item or per-topic. The naming convention signals which kind of file it is at a glance.

---

## App-Context and Architecture Reference Files

For toolkits targeting an existing codebase, two standard reference files accumulate knowledge across sessions:

**`reference/[codebase-name]/APP-CONTEXT.md`** — navigational map ("where is X"):
- Feature locations: what pages/components/routes exist and where they live
- A new Claude session reading this file can immediately locate any feature without touching the repo
- Updated during stories when a new area of the codebase is explored

**`reference/[codebase-name]/ARCHITECTURE.md`** — patterns and conventions ("why and how"):
- How the app is built: state management, auth pattern, API communication, data flow
- Team conventions discovered during exploration
- Updated when a pattern or convention is understood deeply enough to be worth recording

These are separate files because they serve different questions:
- APP-CONTEXT: "where is the save button component?"
- ARCHITECTURE: "why does the save button use optimistic updates instead of waiting for the API?"

Integration:
- `/brief` loads these at session start (STEP 4 in the brief skill)
- WORKFLOW.md for existing-app toolkits includes an explicit step: "update APP-CONTEXT.md with anything new learned during exploration"
- Generated conditionally by `/start-here` when toolkit targets an existing codebase (Phase 7)

---

## Standard Agile Story Workflow

For consulting/agile toolkits targeting an existing app, this is the standard phase structure:

```
Story Intake → Codebase Exploration → Implementation Plan → Implementation → Testing → Summary
```

Each phase has a defined success signal before proceeding to the next:

1. **Story Intake**: Ticket parsed, ACs extracted and confirmed, out-of-scope identified
2. **Codebase Exploration**: Relevant files located, patterns understood, APP-CONTEXT.md updated
3. **Implementation Plan**: Plan confirmed in writing before any code is written — prevents wasted work
4. **Implementation**: Code written per plan, no silent assumptions, stops at decision points
5. **Testing**: Tests pass, coverage thresholds met, test tier confirmed (unit/integration/e2e)
6. **Summary**: Stand-up summary generated, ACTION-ITEMS.md updated, ARCHITECTURE.md updated if new pattern learned

Key rule: the implementation plan is confirmed before any code is written. An unconfirmed plan that turns out wrong wastes the implementation work.

---

## Folder Rename Rule

If a folder is renamed, update the CLAUDE.md Key Documentation section and context navigation table in the same session. File path references go stale immediately — treat them like code dependencies that must be updated together.

This applies to: CLAUDE.md, `.claude/skills/brief/SKILL.md` (in the generated toolkit), and any file that contains explicit folder path references.

### Cloud-Sync Rename Behavior (Verified)

`mv` is safe and correct on cloud-synced paths. It executes a `rename(2)` syscall that preserves inodes. OneDrive (and other providers) use inode-based tracking — the rename is propagated to the server as an atomic PATCH, not as delete+re-upload.

**The "old folder reappears" root cause**: If OneDrive's OAuth token expires while the rename PATCH is still queued but not yet sent to the server, the PATCH is dropped. On the next sync cycle, the server's stale state wins and OneDrive re-creates the folder at the old local name. This is a sync-timing issue, not a `mv` failure.

**Do not use `cp -r + rm -rf`** as an alternative — it creates new inodes, which sync clients interpret as delete+re-upload. It is the wrong approach and actively harmful on cloud-sync paths.

**Detection**: Check if `pwd` contains any of: `~/Library/CloudStorage/` (primary, macOS 12+), `~/OneDrive*/`, `~/Dropbox*/`, `~/Box*/`, `~/Google Drive*/`

**Safe rename procedure on cloud-sync paths**:
1. Use `mv` as normal
2. Wait for the sync client's icon to clear (confirming the PATCH reached the server)
3. Then close the session and open a fresh one in the new folder path

**Exception**: Google Drive in streaming mode (virtual folders) — rename via Finder instead of terminal.

**Implementation**: See Phase 6 of `.claude/skills/start-here/PHASES.md` for the cloud-path detection and user warning logic.

---

## Context Maintenance Cadence

Context docs are not a one-time setup. They require ongoing maintenance to stay useful.

**Recommended cadence**:
- Schedule at minimum 30 minutes per week as a team to review context docs
- Can be folded into retrospectives or run as a standalone touchpoint
- Assign ownership for specific context improvement tasks — do not leave it to "whoever gets to it"

**When AI does something wrong**:
- Ask why it happened
- Find the root cause in the context docs
- Fix it at the source, not by re-prompting in the session

**Treat context docs like code**:
- Refactor when they become bloated
- Cut what does not work
- Add what is needed
- Anyone who finds a prompt improvement should open a PR — include the improvement alongside the feature

---

## Solution Docs and Planning Docs

These are reference patterns, not generated automatically. Create them when the engagement requires deliverable documentation.

For templates, see:
- `.meta/SOLUTION-DOC-TEMPLATE.md` - Standard structure for client-facing deliverables
- `.meta/MEETING-NOTES-TEMPLATE.md` - Standard entry format for meeting consolidation

---

## Summary

This meta-toolkit:
- **Generates** custom toolkits (doesn't require manual editing)
- **Self-destructs** after generation (clean result)
- **Plugin-based** (modular capabilities)
- **Skill-based** (reusable patterns)
- **Model-agnostic** (works with any AI)
- **Use-case agnostic** (email, invoices, code, anything)

**Result**: Professional, clean toolkits in minutes, not hours.
