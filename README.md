# AI Toolkit Accelerator

**A scaffolding system for building systematic AI-assisted workflows**

This meta-toolkit generates custom toolkits for any AI workflow. No pre-built examples. No assumptions about your use case. Just the framework.

---

## 🚀 Quick Start

```
/start-here
```

Claude guides you through an adaptive discovery conversation and generates your toolkit. Takes 15-30 minutes depending on complexity.

**First time?** See [START_HERE.md](START_HERE.md) for what to expect.

---

## What This Does

**Generates custom toolkits** tailored to your workflow through an adaptive discovery conversation:

```bash
# 1. Clone the accelerator
git clone https://github.com/[repo]/ai-toolkit-accelerator my-toolkit
cd my-toolkit

# 2. Open in Claude Code and start generation
/start-here

# 3. Answer discovery questions — Claude branches based on your context
# 4. Get a complete, ready-to-use toolkit
```

**Result**:
- Custom `CLAUDE.md` session guide for YOUR engagement
- Custom `WORKFLOW.md` defining YOUR phases
- Custom `CONFIG.md` with YOUR settings
- Deferred stubs for anything not yet decided — expandable later
- Scaffolding automatically deleted — clean toolkit remains
- Git history and remote connection removed — ready for `git init` as your own repo

**Want to keep a local copy of the accelerator alongside your toolkit?**
Clone once, then copy before running `/start-here`:
```bash
git clone https://github.com/[repo]/ai-toolkit-accelerator
cp -r ai-toolkit-accelerator my-toolkit
cd my-toolkit
/start-here
# The original clone retains its git connection for future accelerator updates
```

---

## The Self-Transforming Pattern

### Before Generation (This Meta-Toolkit)

```
ai-toolkit-accelerator/
├── START_HERE.md                 [Read this first]
├── README.md                     [You are here]
├── DESIGN_PHILOSOPHY.md          [What's baked in and why]
├── .claude/
│   └── skills/
│       └── start-here/           [The only executable skill on the accelerator]
└── .meta/                        [All reference material — deleted after generation]
    ├── ARCHITECTURE.md
    ├── AGENTIC_PATTERNS.md
    ├── DISCOVERY_PIPELINE.md
    ├── PROMPT_ENGINEERING.md
    ├── MODEL_SELECTION.md
    ├── SKILL_GUIDE.md
    ├── SOLUTION_DOC_TEMPLATE.md
    ├── AI_BEHAVIOR_GUIDELINES.md
    ├── base-skills/              [Copied into every generated toolkit's .claude/skills/]
    │   ├── brief/                [→ /brief]
    │   ├── research/             [→ /research]
    │   └── solution-writer/      [→ /solution-writer]
    ├── plugins/                  [Accumulate reusable capabilities here]
    ├── skills/                   [Accumulate reusable workflow patterns here]
    ├── templates/                [Accumulate output format templates here]
    └── skills/                   [Reusable workflow patterns — includes iterative-processing starter]
```

### After Generation (Your Toolkit)

```
my-toolkit/
├── CLAUDE.md                     [Session guide — run /brief every session]
├── README.md                     [Explains YOUR toolkit]
├── GETTING_STARTED.md            [First-use guide]
├── AI_BEHAVIOR_GUIDELINES.md     [Rules for all agents]
├── workflow/
│   ├── WORKFLOW.md               [YOUR phases with detailed guidance]
│   └── CONFIG.md                 [YOUR settings]
├── docs/
│   ├── ACTION_ITEMS.md           [Active tasks and blockers]
│   └── PROJECT_CONTEXT.md        [Client context and stakeholders]
├── reference/
│   └── meetings/
│       └── MEETING_NOTES_SUMMARY.md
├── .claude/
│   └── skills/
│       ├── brief/                [/brief — session orientation]
│       ├── research/             [/research — technical research]
│       └── solution-writer/      [/solution-writer — planning + client docs]
├── skills/
│   ├── toolkit-advisor/          [For modifying toolkit later]
│   └── [selected skills]/        [Copied from .meta/skills/ at generation]
├── plugins/                      [Copied from .meta/plugins/ if selected]
├── templates/                    [Copied from .meta/templates/ if requested]
└── .deferred/                    [Stubs for topics not yet decided]

[All scaffolding deleted automatically]
```

**The scaffolding disappears. Only YOUR toolkit remains.**

---

## Skills Baked Into Every Generated Toolkit

Every toolkit generated from this accelerator receives three skills, copied from `.meta/base-skills/` into the toolkit's `.claude/skills/` at generation time. These are toolkit-operational skills — they have no purpose on the accelerator itself.

### `/brief`
Session orientation. Reads `docs/ACTION_ITEMS.md`, `docs/PROJECT_CONTEXT.md`, and the latest meeting notes, then gives a concise status summary before asking what to work on. Run at the start of every session.

### `/research`
Multi-phase technical research. Decomposes queries into multiple angles, fetches primary sources first, applies a four-perspective review (Researcher, Analyst, Contrarian, Synthesizer), verifies code against live sources, and saves findings to `research/` before summarizing.

### `/solution-writer`
Produces two output files: a solution planning doc (internal) and a solution doc (client-facing). Strict audience separation enforced — the client never sees internal debate.

These three skills work in sequence: `/brief` to orient, `/research` to investigate, `/solution-writer` to document.

---

## How Generation Works

`/start-here` is not a fixed wizard. It opens with a short discovery intake — who this is for, what "done" looks like, whether code or client deliverables are involved — and branches from there. A solo personal workflow and a multi-track client engagement get different questions.

**"I don't know yet" is a valid answer.** Any unknown becomes a deferred stub: a `.deferred/[topic].md` file that explains what would be built, what questions to answer first, and how to expand it. Stubs are surfaced in `CLAUDE.md` every session. When the topic becomes real, describe it and the toolkit expands to meet it — including running `/research` if current patterns and best practices are needed.

---

## What Gets Generated

### Always

- **CLAUDE.md** — session guide with provenance summary of what's active in this toolkit
- **workflow/WORKFLOW.md** — your phases with detailed sub-steps and success criteria
- **workflow/CONFIG.md** — toolkit settings
- **AI_BEHAVIOR_GUIDELINES.md** — behavioral rules for all agents
- **README.md** and **GETTING_STARTED.md**
- **docs/ACTION_ITEMS.md**, **docs/PROJECT_CONTEXT.md**, **reference/meetings/MEETING_NOTES_SUMMARY.md**
- **.claude/skills/** — `/brief` (session orientation), `/research` (technical research), `/solution-writer` (planning + client docs)
- **skills/toolkit-advisor/** — for modifying the toolkit as it evolves

### Conditionally (based on discovery answers)

- Skills and plugins matched to the workflow
- Per-track folder structure (`docs/[track]/`, `research/[track]/`)
- Testing infrastructure (framework-specific: pytest, Jest, xUnit, JUnit)
- Delivery platform setup (Claude Projects, Excel Add-In, Claude Code CLI)
- Path-scoped rules, validation hooks, output templates

### Deferred stubs (for "not yet known" answers)

- **.deferred/[topic].md** — one stub per deferred topic
- Each stub explains what would be built, what questions to answer, and how to expand
- Stubs surface in CLAUDE.md every session
- Expand any stub by describing the need — the toolkit grows to meet it

### Always removed

- **`.git/`** — the entire git directory is wiped. No commit history, no remote connections, no ties back to the accelerator repo. The generated toolkit is a clean directory. Run `git init` when you're ready to start your own repository.

---

## Adaptive Discovery

`/start-here` reads context before asking questions. Early answers determine which questions follow — and "I don't know yet" is handled gracefully as a deferred stub rather than a blocker.

Discovery signals that shape the conversation:
- **Audience** (solo / team / client) — determines scaffolding depth and whether client/internal separation is built in
- **Code involvement** — triggers architecture conventions checklist before phase design, test framework questions, PR guardrails
- **Client deliverables** — triggers delivery platform selection, solution doc pattern, handoff checklist
- **Multi-track** — generates per-track folder structure in `docs/` and `research/`

After the intake, the conversation goes phase by phase: objective, inputs, sub-steps, success signal. Then skills, plugins, and advanced features — only the ones that apply.

---

## Use Cases

This accelerator can generate toolkits for:

- **Documentation Generation** - Analyze code, generate comprehensive docs
- **Email Composition** - Draft personalized emails in your style
- **Code Review** - Systematic code analysis with checklists
- **Research Synthesis** - Analyze multiple sources, generate summaries
- **Data Processing** - Transform and validate datasets
- **Content Creation** - Generate structured content with templates
- **Decision Support** - Evaluate options, recommend actions
- **Quality Assurance** - Systematic testing and validation workflows
- **Meeting Notes** - Consistent format for meeting documentation
- **Learning Capture** - Extract and organize learnings from materials

**Any systematic AI-assisted workflow can be a toolkit.**

---

## Architecture

### `.meta/` — The Library

Everything in `.meta/` is reference material that informs toolkit generation. None of it executes directly — it's read by Claude during generation and consulted when building or extending a toolkit. It gets deleted from the copy after generation; the original accelerator keeps it as your growing library.

**Guides**: `ARCHITECTURE.md`, `SKILL_GUIDE.md`, `PLUGIN_GUIDE.md`, `PHASES_GUIDE.md`, `PROMPTS_GUIDE.md`, `TESTING_GUIDE.md`, `AGENTIC_PATTERNS.md`, `DISCOVERY_PIPELINE.md`, `PROMPT_ENGINEERING.md`, `MODEL_SELECTION.md`

**Templates**: `SOLUTION_DOC_TEMPLATE.md`, `MEETING_NOTES_TEMPLATE.md`, `AI_BEHAVIOR_GUIDELINES.md` (copied into every generated toolkit)

**Permission sets** — four modular layers that combine into a single `settings.json` for the generated toolkit:
- `settings.template.json` — base layer, always included (file navigation, safe git operations, safety deny rules)
- `settings.research.json` — adds WebSearch, WebFetch, curl, and research domains (add when toolkit needs live web access)
- `settings.developer.json` — adds git write ops, Python/pip, Azure/AWS CLI, test runners (add when toolkit involves writing or deploying code)
- `settings.diagnostic.json` — adds environment inspection tools, read-only cloud CLI commands (add when toolkit needs to audit infrastructure)

The generation conversation asks what the toolkit needs access to and builds `settings.json` by merging the relevant layers. A solo personal workflow may need only the base. A full client engagement toolkit running code, research, and cloud deployments gets all four. See `.meta/PERMISSIONS_TEMPLATE_README.md` for merge rules.

**Accumulation folders** — grow these over time as you build toolkits:
- `.meta/plugins/` — reusable domain-specific capabilities (processors, prompt sets for specific tools)
- `.meta/skills/` — reusable workflow patterns extracted from past engagements
- `.meta/templates/` — output format templates for consistent deliverables
- `.meta/skills/` — reusable workflow patterns (includes `iterative-processing` as a starter reference)

### `.claude/` — The Execution Layer

The folder Claude Code watches automatically. Skills here are executable as `/skill-name` commands. On the accelerator itself, only one skill lives here: `/start-here`. The other operational skills (`/brief`, `/research`, `/solution-writer`) live in `.meta/base-skills/` and get copied into every generated toolkit's `.claude/skills/` at generation time — they're toolkit tools, not accelerator tools.

---

## Philosophy

### What This Is

- ✅ **Adaptive generator**: Branches on context, not a fixed wizard
- ✅ **Pattern-embedded**: Behavioral discipline, research integrity, session management baked in
- ✅ **Handles unknowns**: Deferred stubs for anything not yet decided
- ✅ **Always expandable**: The toolkit grows as the engagement evolves
- ✅ **Self-cleaning**: Scaffolding disappears after generation
- ✅ **Use-case agnostic**: Works for any systematic AI-assisted workflow

### What This Is Not

- ❌ A fixed wizard (questions branch based on your context)
- ❌ A one-shot artifact (it expands with the engagement)
- ❌ Pre-built for a specific domain (you define everything)
- ❌ A manual template to fill in

---

## Examples of Generated Toolkits

**After using this accelerator, you might have**:

```
~/toolkits/
├── email-toolkit/              # Generated for email composition
├── invoice-toolkit/            # Generated for invoice processing
├── code-review-toolkit/        # Generated for code analysis
└── learning-toolkit/           # Generated for learning capture
```

**Each one**:
- Generated in 15-30 minutes
- Custom to its purpose
- Clean (no scaffolding)
- Ready to use immediately
- Can reference shared plugins/skills from `.meta/` in the accelerator

---

## Workflow

### 1. Generate Your First Toolkit

```bash
# Clone and generate in place
git clone https://github.com/[repo]/ai-toolkit-accelerator my-toolkit
cd my-toolkit
/start-here

# Answer the discovery questions
# Toolkit generates in place, git history removed, ready to use
```

### 2. Expand as the Engagement Evolves

The toolkit grows with you:
- New requirement surfaces → describe it, `/toolkit-advisor` integrates it
- Deferred stub becomes real → describe the need, the toolkit adds the component
- Reusable pattern emerges → extract as skill, add to the accelerator

### 3. Add to the Accelerator

```bash
# Back to the accelerator
cd ../ai-toolkit-accelerator

# Add discovered patterns to .meta/plugins/, .meta/skills/, or .meta/templates/
# Available for the next toolkit generation
```

### 4. Generate the Next Toolkit

```bash
# Clone fresh or copy from your local accelerator
git clone https://github.com/[repo]/ai-toolkit-accelerator next-toolkit
cd next-toolkit
/start-here
# Now offers your accumulated skills and plugins from the repo
```

---

## Advanced Features

### Testing Infrastructure (Optional)

If your toolkit includes code, you can generate testing structure:
- **Python** (pytest) - conftest.py, test examples, requirements
- **JavaScript/TypeScript** (Jest) - jest.config.js, test examples
- **C#** (.NET xUnit) - test classes and configuration
- **Java** (JUnit) - test classes and setup

The testing directory is optional and can be deleted if not needed.

### Path-Scoped Rules (Optional)

Load AI guidance only for specific file types:
- Security rules when reviewing auth code
- API conventions when editing API handlers
- Testing rules when modifying tests

Saves context tokens and provides targeted help.

### Validation Hooks (Optional)

Automatically validate actions:
- **PreToolUse**: Block dangerous operations before they happen
- **PostToolUse**: Auto-format or validate after changes

Examples: Block `rm -rf` commands, auto-format code after editing

---

## Success Criteria

Your generated toolkit is ready when:

✅ README explains YOUR toolkit (not how to build one)  
✅ WORKFLOW defines YOUR phases with detailed guidance  
✅ CONFIG controls YOUR preferences  
✅ No scaffolding files remain  
✅ Clean, professional result  
✅ Ready to use immediately  

---

## Time Investment

| Activity | Duration |
|----------|----------|
| Copy accelerator | 10 seconds |
| Run `/start-here` discovery conversation | 15-30 minutes |
| Review generated files | 5-10 minutes |
| Fill in `PROJECT_CONTEXT.md` and `ACTION_ITEMS.md` | 10-20 minutes |
| **Total to working toolkit** | **30-60 minutes** |

**vs. building from scratch: 4-18 hours**

---

## Getting Started

1. Read [START_HERE.md](START_HERE.md) to understand what to expect
2. Copy this accelerator to a new directory
3. Open in Claude Code
4. Type `/start-here`
5. Answer the discovery questions
6. Use your generated toolkit

**Plugins and skills come later as you discover reusable patterns.**

---

## For Developers

### Understanding the System

- `DESIGN_PHILOSOPHY.md` — what's baked in and the reasoning behind each pattern
- `.meta/ARCHITECTURE.md` — how the self-transforming generator works
- `.meta/AGENTIC_PATTERNS.md` — reusable agentic workflow patterns
- `.meta/PROMPT_ENGINEERING.md` — prompts as composable artifacts

### Creating Plugins and Skills

- `.meta/PLUGIN_GUIDE.md` — plugin structure and integration
- `.meta/SKILL_GUIDE.md` — skill structure, A-J build sequence, durability rules
- `.meta/PHASES_GUIDE.md` — how to structure phase files
- `.meta/PROMPTS_GUIDE.md` — effective prompt templates

---

## Need Help?

- **Getting started**: Read [START_HERE.md](START_HERE.md)
- **Understanding architecture**: Read `.meta/ARCHITECTURE.md`
- **Understanding the design rationale**: Read [DESIGN_PHILOSOPHY.md](DESIGN_PHILOSOPHY.md)
- **Skill pattern reference**: See `.meta/skills/iterative-processing/`
- **Claude Code help**: `/help`
- **Issues**: https://github.com/anthropics/claude-code/issues

---

**Version**: 4.0
**Created**: 2026-05-21
**Updated**: 2026-07-03
**Platform**: Mac, Windows, Linux (Claude Code required)
**Purpose**: Generate adaptive, expandable AI workflow toolkits for any use case
