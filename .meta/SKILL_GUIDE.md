# Skill Creation Guide

**When to use this file**: Pull it up when you are building a skill - either as a client deliverable or for your own personal use. Not bootstrapped into every toolkit. Lives in `.meta/` as a reference.

This guide serves two purposes. Use the section that matches what you are building:

- **Section A - Client Skill Delivery**: Full framework for skills that will be handed off to a client. Use when the skill is a deliverable.
- **Section B - Personal Skill Reference**: A short "things to consider" when building a skill for your own workflow. Use when you are not delivering to a client and do not need the full framework.

---

## What Makes a Good Skill?

A skill should be:
- ✅ **Reusable** - Applicable to multiple use cases
- ✅ **Pattern-based** - Represents a general approach, not specific implementation
- ✅ **Well-documented** - Clear purpose, when to use, how to integrate
- ✅ **Self-contained** - Can be understood without external context

---

## When to Create a Skill

Create a skill when you identify a **recurring pattern** across toolkits:

### Examples of Good Skills

**1. multi-step-analysis**
- **Pattern**: Break down complex analysis into phases
- **Use cases**: Code analysis, document review, data examination
- **Why it's a skill**: The pattern of "intake → structure → detail → synthesis → report" applies broadly

**2. iterative-processing**
- **Pattern**: Process items one at a time with consistent structure
- **Use cases**: Batch file processing, email composition, document generation
- **Why it's a skill**: The pattern of "load batch → for each item → process → collect results" applies broadly

**3. validation-pattern**
- **Pattern**: Multi-level validation with clear criteria
- **Use cases**: Data validation, quality checks, compliance reviews
- **Why it's a skill**: The pattern of "check completeness → check format → check rules → report issues" applies broadly

**4. content-generation**
- **Pattern**: Structured approach to creating content
- **Use cases**: Writing documents, generating reports, composing messages
- **Why it's a skill**: The pattern of "understand requirements → gather context → draft → refine → finalize" applies broadly

---

## Skill Structure

There are **two types of skills** depending on how they're used:

### Type 1: Reference Skills (User-Created Patterns)

For patterns you extract and want to reference when building toolkits:

```
skills/[skill-name]/
├── README.md          # What it is, when to use, how to integrate
├── PHASES.md          # Pattern structure with phases/steps
└── PROMPTS.md         # AI prompt templates for applying the pattern
```

These are **documentation/reference** - used by you or AI when designing workflows.

---

### Type 2: Claude Code Skills (Invokable Commands)

For skills that Claude Code should execute via `/skill-name` commands:

```
.claude/skills/[skill-name]/
├── SKILL.md           # REQUIRED - Main instructions (with YAML frontmatter)
├── PHASES.md          # Optional - Supporting structure
├── PROMPTS.md         # Optional - Supporting templates
└── [other files]      # Optional - Additional resources
```

**Critical Requirements for Claude Code Skills**:

1. **Location**: MUST be in `.claude/skills/[skill-name]/` (note the `.claude/` prefix)
2. **Filename**: Main file MUST be named `SKILL.md` (uppercase, not `skill.md` or `README.md`)
3. **Frontmatter**: MUST have YAML frontmatter with `description:` field

**Example SKILL.md**:

```markdown
---
description: Brief description of what this skill does and when to use it
name: skill-name                    # Optional - uses directory name if omitted
disable-model-invocation: false     # Optional - set true for manual-only
when_to_use: Additional context     # Optional - when Claude should invoke
---

# Skill Name

Your skill instructions here...
```

**Discovery Locations** (Claude Code checks in this order):
1. `.claude/skills/<skill-name>/SKILL.md` (project-specific) ✅ **Use this**
2. `~/.claude/skills/<skill-name>/SKILL.md` (personal, all projects)
3. Plugins: `<plugin>/skills/<skill-name>/SKILL.md`

**Usage**: Type `/skill-name` in Claude Code to invoke

---

### When to Use Each Type

| Type | Purpose | Location | Example |
|------|---------|----------|---------|
| **Reference Skill** | Pattern documentation | `skills/` | multi-step-analysis, iterative-processing |
| **Claude Code Skill** | Executable command | `.claude/skills/` | start-here, toolkit-advisor |

**Note**: A skill can be both types - reference docs in `skills/` and executable in `.claude/skills/`

### README.md Template

```markdown
# [Skill Name]

**Pattern**: [One-line description of the pattern]

---

## What This Skill Provides

[Explain the pattern this skill represents]

---

## When to Use

Use this skill when:
- [Condition 1]
- [Condition 2]
- [Condition 3]

**Do NOT use when**:
- [Anti-pattern 1]
- [Anti-pattern 2]

---

## How It Works

[Brief overview of the pattern structure]

---

## Integration with Workflow

This skill can be applied to workflow phases by:
1. [Integration step 1]
2. [Integration step 2]
3. [Integration step 3]

---

## Examples

### Example 1: [Use Case]
[Show how the pattern applies]

### Example 2: [Use Case]
[Show how the pattern applies]

---

**Version**: 1.0
**Created**: [Date]
**Applicable to**: [Types of workflows]
```

### PHASES.md Template

```markdown
# [Skill Name] - Pattern Structure

This document defines the phases/steps of this pattern.

---

## Phase 1: [Name]

**Objective**: [What this phase accomplishes]

**Actions**:
1. [Action 1]
2. [Action 2]
3. [Action 3]

**Output**: [What this phase produces]

---

## Phase 2: [Name]

**Objective**: [What this phase accomplishes]

**Actions**:
1. [Action 1]
2. [Action 2]
3. [Action 3]

**Output**: [What this phase produces]

---

[Continue for all phases...]

---

## Success Criteria

This pattern is successfully applied when:
- ✅ [Criterion 1]
- ✅ [Criterion 2]
- ✅ [Criterion 3]
```

### PROMPTS.md Template

```markdown
# [Skill Name] - AI Prompt Templates

These templates guide how to apply this pattern.

---

## Main Application Prompt

When applying this skill to a workflow:

\```
[Prompt template showing how AI should approach using this pattern]
\```

---

## Phase-Specific Prompts

### Phase 1: [Name]

\```
[Prompt template for this phase]
\```

### Phase 2: [Name]

\```
[Prompt template for this phase]
\```

[Continue for all phases...]

---

## Behavioral Reminders

When using this skill:
- [Specific guidance related to this pattern]
- [Reminder about avoiding assumptions]
- [Reminder about asking questions]
```

---

## Creating a New Skill

### Step 1: Identify the Pattern

Ask yourself:
- Have I seen this workflow structure before?
- Could this approach work for other use cases?
- What's the general pattern, independent of specifics?

### Step 2: Name It

Use kebab-case naming:
- Good: `multi-step-analysis`, `iterative-processing`, `validation-pattern`
- Bad: `OmniScriptDocumenter`, `EmailTool`, `SpecificTask`

### Step 3: Document the Pattern

Create the three files (README, PHASES, PROMPTS) following the templates above.

Focus on:
- **General structure**, not specific implementation
- **When to use**, not just what it does
- **How to apply**, not just what the pattern is

### Step 4: Test Reusability

Ask:
- Can I explain this pattern without mentioning specific domains?
- Would someone working on a different use case understand how to apply this?
- Does this pattern add value, or is it just documenting the obvious?

---

## Best Practices

### ✅ DO
- Extract patterns from successful toolkits
- Document WHY to use the skill, not just HOW
- Include examples from multiple domains
- Keep skills focused on one pattern
- Update skills as you learn better approaches

### ❌ DON'T
- Create skills for one-off use cases
- Include domain-specific implementation details
- Make skills too generic (e.g., "process-data")
- Create skills without testing reusability
- Duplicate functionality across skills

---

## Skill vs. Plugin

**Confused whether to create a skill or plugin?**

| Aspect | Skill | Plugin |
|--------|-------|--------|
| **Nature** | Workflow pattern | Specific capability |
| **Content** | Process structure | Implementation code/prompts |
| **Reusability** | Cross-domain pattern | Domain-specific tool |
| **Example** | "multi-step-analysis" | "omniscript-parser" |
| **Contains** | PHASES, PROMPTS | processor.py, CONFIG |

**Rule of thumb**: If it's about HOW to structure work, it's a skill. If it's about WHAT capability to provide, it's a plugin.

---

## Maintenance

Skills should be:
- **Reviewed** after each toolkit creation (did the pattern work?)
- **Updated** when better approaches are discovered
- **Retired** if they're never used or superseded by better patterns

---

## Example: Creating "multi-step-analysis" Skill

### 1. Pattern Identified
Noticed that documentation toolkit, code review toolkit, and data analysis toolkit all follow:
- Intake data
- Analyze structure
- Examine details
- Synthesize findings
- Generate report

### 2. Named
`multi-step-analysis` - describes the pattern of breaking analysis into phases

### 3. Documented
Created README.md explaining:
- Pattern: Progressive deepening of analysis
- When to use: Complex analysis tasks requiring thoroughness
- How it works: 5-phase structure from broad to specific

Created PHASES.md with:
- Phase 1: Data Intake (load and prepare)
- Phase 2: Structure Analysis (understand organization)
- Phase 3: Detailed Examination (deep dive)
- Phase 4: Synthesis (connect findings)
- Phase 5: Report Generation (communicate results)

Created PROMPTS.md with:
- Templates for each phase
- Questions to ask
- How to transition between phases

### 4. Tested Reusability
Applied to:
- ✅ Code analysis (worked)
- ✅ Document review (worked)
- ✅ Meeting notes analysis (worked)

Pattern confirmed reusable!

---

---

## Section A - Client Skill Delivery

These standards apply to any Claude skill built for client delivery or team use. They reflect what actually works in practice.

### The A-to-J Build Sequence

Build every skill in this order. Do not skip steps.

```
A  Understand the data        What inputs exist, what format, what edge cases
B  Define the logic           What the skill must do, step by step, with exact rules
C  Write the prompt           Full self-sufficient prompt following the template below
D  Test with real data        Run it. Find what breaks.
E  Refine                     Fix the breaks. Tighten the pre-flight. Clarify the output.
F  Confirm with owner         Verify the logic and output match what was expected
G  Decide delivery platform   Claude Project / Excel Add-In / Claude Code CLI
H  Build the wrapper          Solution doc, three-field creation block, setup instructions
I  Train the user             Walk through it once. Note anything that needs clarification.
J  Hand off                   Handoff checklist complete, internal sections removed
```

Do not mark a skill complete until step J is done.

---

### Self-Sufficiency Test

A skill is self-sufficient when it works correctly even if the user has never read the solution doc. Before finalizing any skill prompt, verify:

- [ ] The skill states what it does in the first sentence
- [ ] Every required input is checked with a hard stop if missing
- [ ] Every likely-but-not-certain input issue is caught with a soft check (ask, don't stop)
- [ ] The skill confirms what it found and what it will do before executing
- [ ] The output format is fully specified in the prompt, not assumed
- [ ] Error messages state exactly what is wrong and exactly how to fix it
- [ ] The skill does not depend on the user having read anything outside the prompt

---

### Required Prompt Structure

Every Claude skill prompt must follow this structure:

```
[One sentence: what this skill is, where it runs, what it does]

---

PRE-FLIGHT — Run every check below before any analysis.

COMMUNICATION RULE: Keep all pre-flight messages to 1-2 lines. Hard stops: state
problem + fix in one sentence. Soft checks: one line question. Confirmations: one
medium line. Shift to normal conversation if user asks questions — return to brief
responses once resolved.

STEP 1 — [Locate or confirm the required input]
[Hard stop logic: what to check, what to say if missing — one sentence stating
the problem and exactly how to fix it]

STEP 2 — [Validate secondary requirements]
[Hard stop or soft check as appropriate]

STEP 3 — [Soft checks for likely user errors]
[Ask, don't stop. Date checks, format checks, threshold checks, etc.]

STEP 4 — Confirm before running
[One medium line: what was found, what will happen. Proceed automatically.]

---

[DATA/FILE STRUCTURE REFERENCE — exact column names, naming conventions, key fields]

---

[ANALYSIS / CORE LOGIC — numbered steps, exact rules, what NOT to do]

---

[OUTPUT FORMAT — exact structure, what to include, disclaimers to always append]
```

**Rules**:
- Hard stops are for inputs that are truly required and cannot be reasonably inferred
- Soft checks are for inputs that are likely but not certain (ask, don't block)
- The threshold or key parameter must accept any natural format: `10%`, `threshold=10%`, or a number mentioned naturally in the message
- For Excel-based skills: always detect environment (desktop vs web) before running
- Always confirm what was found and what will happen before executing

---

### Three-Field Creation Standard

When creating a skill inside Claude Projects or the Excel Add-In, use exactly these three fields:

| Field | What to write |
|---|---|
| **Name** | Short, action-oriented. What the user types to invoke it. |
| **Description** | Trigger language. This is how Claude decides when to suggest the skill. Write it as the sentence a user would say: "When the user wants to..." |
| **Instructions** | The full self-sufficient prompt from the template above. |

The description field is not a summary - it is trigger language. Write it to match what the user will actually say.

---

### Platform Decision Matrix

Every skill doc must declare its delivery platform. Choose before building the wrapper.

| Platform | When to use | Key constraints |
|---|---|---|
| **Claude Project** (web or desktop) | File upload and analysis, no Excel required. Web and desktop behave identically. | Requires Team or Enterprise plan for sharing. |
| **Claude for Excel Add-In** | Analysis that runs inside Excel, annotates cells, creates new tabs. | Desktop vs web behavior differs for cross-file access. Always detect environment in pre-flight. |
| **Claude Code CLI** | Local file transformation, .xlsx generation, automated output. | Technical — best suited for developers and power users rather than end clients. |

When the platform is Excel Add-In, the pre-flight must include an environment detection step that checks whether the user is on desktop or web and adjusts behavior accordingly.

---

### Word Document Generation

Two patterns depending on content type. Choose before building the generation script.

**python-docx** (preferred for most deliverables):
- Use when the output contains tables, specific formatting, or styled sections
- Produces reliable table formatting that matches client expectations
- Reusable generation script pattern: build once, parameterize for different content

**pandoc** (use for simple prose):
- Converts markdown to .docx cleanly when there are no complex tables
- Faster for simple narrative documents
- Breaks on complex table formatting — do not use if tables are present

**Rule**: When in doubt, use python-docx. Pandoc table output is unpredictable and has required rework in practice.

**Pattern**: Build a reusable generation script early in the engagement and parameterize it rather than writing one-off scripts per deliverable.

---

### Testing Checklist

Before marking any skill complete:

- [ ] Tested with real input data, not sample/invented data
- [ ] Hard stop triggered correctly when required input is missing
- [ ] Soft check fires correctly for likely-but-not-certain issues
- [ ] Confirmation step shows correct summary before executing
- [ ] Output matches the specified format exactly
- [ ] Error messages are specific: what is wrong, how to fix it
- [ ] Tested on the target platform (Project / Excel / CLI)
- [ ] Confirmed with the skill owner that output is correct

---

### Handoff Checklist

Before marking any deliverable client-ready:

- [ ] All internal-only sections removed or flagged
- [ ] No references to internal Slack channels, internal URLs, or personal names in forward-looking instructions
- [ ] Solution doc reviewed by at least one other team member
- [ ] Three-field creation block complete and accurate
- [ ] Setup instructions tested end-to-end by someone other than the builder
- [ ] Planning doc moved to `.archive/` if work is finalized

---

### Durability Rules for Skills and CLAUDE.md

Skills and CLAUDE.md are read by future sessions that have no memory of when they were written. These things go stale and should never be hardcoded:

- **Specific meeting numbers or counts** ("Meeting 7", "currently 5 meetings")
  Use instead: "the most recent entry", "check file for current count"

- **Specific dates or week counts** ("as of 2026-05-28", "Week 2 of 4")
  Use instead: "read docs/ACTION_ITEMS.md for current status"

- **Specific blockers or decisions in skill files**
  These belong in `docs/`, not in skills. Skills read files — they do not store state.

- **Model version names in instructions** ("Sonnet 4.5", "GPT-4o")
  Use instead: "the current model", "the model selected for this session"
  Only name a model when it is a hard requirement for a specific capability.

- **Personal names in forward-looking instructions** ("Edgar will confirm", "Edgar to review")
  Use instead: "the developer", "the engagement lead", "you"

**Durability test**: If this skill were read 6 months from now, would any sentence be misleading? If yes, make it dynamic.

---

## Section B - Personal Skill Reference

Use this when building a skill for your own workflow - not a client deliverable, not a team tool. The full A-J framework is overkill here. Instead, work through these questions before writing the prompt.

**Things to consider**:

- Will this skill make sense to you six months from now without any extra context? If not, the prompt is relying on memory rather than being self-contained.
- What is the one thing this skill does? If you cannot answer in one sentence, it is probably doing too much.
- What input does it need? Is that input always present, or do you need a check before it runs?
- Is there anything you always forget to do before running this? That is your pre-flight.
- What does "done" look like? If the output format is not in the prompt, Claude will make something up each time.
- Are there edge cases you already know about? Put them in the prompt now, not after the first time it breaks.
- Does it need to confirm before executing, or is it safe to run without asking? Destructive or irreversible actions should always confirm.
- If someone else picked this up cold, would they understand what it does and how to use it? Even personal skills benefit from a one-sentence description at the top.

**The minimum a personal skill needs**:
1. One sentence stating what it does and where it runs
2. A check for any input it truly cannot proceed without
3. A defined output format so the result is consistent across runs

Everything else from Section A is optional depending on complexity.

---

**Version**: 2.1
**Last Updated**: 2026-07-03
**Purpose**: Guide skill creation for toolkit accelerator
