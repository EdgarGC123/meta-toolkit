# PROMPTS.md Structure Guide

**Purpose**: How to create PROMPTS.md files that provide AI with effective prompt templates for applying skill patterns.

**When to create**: When a skill needs specific guidance on how AI should communicate or structure its responses when using the pattern.

---

## What is PROMPTS.md?

PROMPTS.md provides **template text that AI should use** when applying a skill pattern. It's about HOW to communicate and structure responses, not WHAT to do (that's in PHASES.md).

**Example**: PHASES.md says "identify themes across sources." PROMPTS.md shows the AI exactly how to present those themes to the user, including formatting, what to ask, and how to structure progress updates.

---

## When NOT to Create PROMPTS.md

Don't create PROMPTS.md if:
- The skill is self-explanatory (obvious how AI should respond)
- PHASES.md + README.md provide sufficient guidance
- The skill is reference material only

**Rule of thumb**: If you find yourself writing "AI should say..." in PHASES.md or README.md, that content belongs in PROMPTS.md instead.

---

## PROMPTS.md Structure

### Required Sections

#### 1. Header
```markdown
# [Skill Name] - AI Prompt Templates

These templates guide how to apply the [skill name] pattern.
```

#### 2. Main Application Prompt

```markdown
## Main Application Prompt

When starting [skill name]:

\```
[Complete template showing how AI should introduce the pattern and ask initial questions]
\```
```

**Purpose**: The opening move. What should AI say when this skill is first invoked?

**What to include**:
- Brief explanation of what AI will do
- Questions to ask user upfront
- Outline of the phases/structure
- Set expectations for how long it will take or what's involved

**Example structure**:
```
I'll help you [accomplish goal] using a systematic [N]-phase approach.

Let me start by understanding what we're working with:
1. [Question about scope]
2. [Question about requirements]
3. [Question about format]

Once I understand the scope, I'll proceed through these phases:
- Phase 1: [Name]
- Phase 2: [Name]
[...]

I'll update you at each phase and ask clarifying questions as needed.
```

#### 3. Phase-Specific Prompts

For each phase that needs specific structure:

```markdown
## Phase [N]: [Phase Name] Prompt

\```
[Template showing how AI should present this phase]

[Progress indicator]
[Phase-specific content structure]
[Transition to next phase or questions to ask]
\```
```

**When to include**: When the phase has a specific output format or communication style.

**When to skip**: If the phase is straightforward and doesn't need templated output.

---

### Optional Sections

#### Error Recovery Prompts

```markdown
## Error Recovery Prompts

### When [Specific Error Occurs]

\```
[Template for handling this error gracefully]
\```
```

**When to include**: When specific errors are expected and should be handled with specific messaging.

#### Behavioral Reminders

```markdown
## Behavioral Reminders

When using this skill:
- [Specific guidance 1]
- [Specific guidance 2]
- [Specific guidance 3]
```

**When to include**: When this skill has specific behavioral considerations (e.g., "never invent citations", "always verify before proceeding").

---

## Writing Guidelines

### 1. Write Complete Templates, Not Fragments

❌ **Bad**: "Explain what you found"
✅ **Good**:
```
Phase 2 complete. I've identified [N] major themes:

**Theme 1: [Name]**
- Appears in: [Sources]
- Key points: [Summary]

**Theme 2: [Name]**
- Appears in: [Sources]
- Key points: [Summary]

Should I proceed to Phase 3: Cross-referencing?
```

### 2. Show Formatting in Templates

Use actual markdown formatting in templates:
- **Bold** for emphasis
- `Code blocks` for technical items
- Lists for structured information
- Headers for sections

### 3. Include Progress Indicators

Templates should show where AI is in the workflow:
```
Phase 2/5: Identifying themes
Progress: [=========>          ] 40%
```

Or simpler:
```
Phase 2: Theme identification (2 of 5)
```

### 4. Include Placeholder Syntax

Use clear placeholders:
- `[Description]` for content AI should generate
- `[N]` for numbers AI should fill in
- `[User-specified-value]` for things from user input

### 5. Show Transition Language

Templates should include how to transition between phases:
```
...

Once confirmed, I'll proceed to Phase 3: Cross-referencing claims.
```

Or:
```
...

Questions before proceeding:
1. [Question]
2. [Question]

Should I move to the next phase?
```

### 6. Balance Verbosity

- **Too terse**: AI might not provide enough context
- **Too verbose**: Wastes tokens, user skims past
- **Just right**: Clear, structured, scannable

**Good length**: 3-8 lines per prompt template for most phases.

---

## Types of Prompts

### 1. Introduction Prompts
Set expectations, gather initial info, outline process.

### 2. Progress Update Prompts
Show what's been done, what's next, ask for confirmation.

### 3. Validation Prompts
Present findings, ask for verification or approval.

### 4. Error Handling Prompts
Explain what went wrong, suggest solutions, ask how to proceed.

### 5. Completion Prompts
Summarize what was accomplished, offer next actions.

---

## Integration with PHASES.md

**Division of labor**:

| PHASES.md | PROMPTS.md |
|-----------|------------|
| "For each source, identify the main argument" | Shows template: "**Source 1: [filename]**\n- Main argument: [summary]\n- Evidence: [points]" |
| "Validation checkpoint: ensure all sources reviewed" | Shows template: "Validation:\n✓ All [N] sources reviewed\n✓ Main arguments documented\n✓ Ready to proceed" |
| "Ask user about priority themes" | Shows template: "I found [N] themes. Should I:\n1. Focus on all of them?\n2. Prioritize [specific ones]?" |

**Think of it as**:
- PHASES.md = Recipe (what ingredients, what order, how to know it's done)
- PROMPTS.md = Presentation guide (how to plate the dish, how to describe it)

---

## Examples of Good vs Bad Prompts

### Bad Example (Too Vague)
```markdown
## Phase 1 Prompt

Tell the user what you're doing and show the results.
```

**Problem**: No structure, no template, AI has to guess formatting.

### Good Example (Clear Template)
```markdown
## Phase 1: Document Reading Prompt

\```
Phase 1: Reading all source documents

I'll go through each document systematically:

[For each document:]
- **Document**: [filename]
- **Main argument**: [one-sentence summary]
- **Supporting evidence**: [2-3 key points]
- **Questions/unclear points**: [if any]

[After all documents:]
I've reviewed [N] source documents covering these topics:
1. [Topic 1]
2. [Topic 2]
3. [Topic 3]

Should I proceed to identify themes across these sources?
\```
```

**Why this works**: Clear structure, shows formatting, includes placeholders, has transition.

---

## Prompt Engineering Best Practices

### 1. Be Specific About Format
If you want bullet points, show bullet points in the template.
If you want numbered lists, show numbered lists.
If you want markdown tables, show markdown tables.

### 2. Include "Safety Checks"
Build in reminders for critical behavior:
```
I found [N] claims. Verifying each against original sources:

**Claim 1**: [Statement]
- Source: [Document, page/section]
- Verification: [Direct quote from source]
[Never paraphrase or remember from earlier - always check the actual text]
```

### 3. Show Conditional Branches
```
I encountered [situation].

[If option A applies:]
This suggests we should [action A]. Should I proceed?

[If option B applies:]
This suggests we should [action B]. Should I proceed?
```

### 4. Use Checklists for Validation
```
Validation checks:
- [ ] All required fields present
- [ ] No duplicate entries
- [ ] Format matches expected structure
- [ ] No errors or warnings

[If all checked: proceed]
[If any unchecked: explain issue and ask how to fix]
```

---

## Advanced Patterns

### Pattern: Two-Stage Confirmation
```markdown
## Phase 3: Synthesis Proposal Prompt

\```
Phase 3: Creating synthesis structure

I'm proposing this structure:

[Full proposed structure shown]

Does this work for your needs, or should I adjust:
- More detail in certain sections?
- Different organization?
- Additional sections?

[Wait for confirmation before generating full content]
\```
```

**When to use**: Expensive or time-consuming phases where preview is valuable.

### Pattern: Incremental Disclosure
```markdown
## Phase 2: Theme Identification Prompt

\```
Phase 2: Identifying themes

I've identified [N] themes. Here are the first 3:

**Theme 1**: [Name and brief description]
**Theme 2**: [Name and brief description]  
**Theme 3**: [Name and brief description]

Should I:
1. Show remaining themes now
2. Proceed to detail these 3 first
3. Adjust these themes before continuing
\```
```

**When to use**: When output might be large and user wants control over depth.

### Pattern: Batch Progress Updates
```markdown
## Iterative Processing Progress Prompt

\```
Processing batch: [current] of [total]

✓ Completed: [list]
→ Current: [item name]
⏳ Remaining: [N] items

Estimated time: [X] minutes

[Should include option to pause/adjust after each batch of ~5-10 items]
\```
```

**When to use**: Long-running iterative processes where progress visibility matters.

---

## Quick Reference Template

```markdown
# [Skill Name] - AI Prompt Templates

These templates guide how to apply the [skill name] pattern.

---

## Main Application Prompt

When starting [skill name]:

\```
I'll help you [goal] using [approach].

[Initial questions]

I'll proceed through these phases:
- Phase 1: [Name]
- Phase 2: [Name]

[Expectation setting]
\```

---

## Phase 1: [Name] Prompt

\```
Phase 1: [Name]

[Structured output template]

[Transition question/statement]
\```

---

## Error Recovery Prompts

### When [Error Type]

\```
[Error handling template]
\```

---

## Behavioral Reminders

When using this skill:
- [Reminder 1]
- [Reminder 2]

---

**Version**: 1.0
**Prompt Style**: [e.g., Structured progress updates, Conversational, Formal, etc.]
```

---

## Maintenance

Update PROMPTS.md when:
- Users consistently ask for different formatting
- AI produces outputs that don't match expectations
- New error patterns emerge that need specific handling
- Transitions between phases are unclear

Don't update for one-off preferences - only when the PATTERN needs adjustment.

---

**Version**: 1.1
**Last Updated**: 2026-07-03
**Purpose**: Guide for creating PROMPTS.md files in skills
