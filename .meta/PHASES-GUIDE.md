# PHASES.md Structure Guide

**Purpose**: How to create PHASES.md files for skills that represent multi-phase workflow patterns.

**When to create**: When a skill represents a process with multiple distinct steps that should be executed in order.

---

## What is PHASES.md?

PHASES.md documents the **structure of a workflow pattern**. It's not about implementing a specific task, but about defining a reusable process that can be applied to different situations.

**Example**: The "iterative-processing" skill has PHASES.md because the pattern (load → process → validate → accumulate → review) applies to many batch tasks, not just one specific project.

---

## When NOT to Create PHASES.md

Don't create PHASES.md if:
- The skill is a single-step operation (use README.md only)
- The skill provides reference information (use README.md only)
- The phases are obvious or trivial
- The skill is about a capability, not a process

**Example**: A "markdown-formatting" skill probably doesn't need PHASES.md - it's a single capability, not a multi-phase process.

---

## PHASES.md Structure

### Required Sections

#### 1. Header with Context
```markdown
# [Skill Name] - Pattern Structure

**Note on Phase Count**: [Clarify that phase count is flexible, this is an example]
```

**Why**: Sets expectations that this is a pattern, not a rigid requirement. The phase count shown is an example for THIS use case.

#### 2. Progress Tracking Checklist
```markdown
## Progress Tracking

Copy this checklist and update as you work:

\```
[Workflow Name] Progress:
- [ ] Phase 1: [Name]
- [ ] Phase 2: [Name]
- [ ] Phase 3: [Name]
[...]
\```
```

**Why**: Gives AI (and user) a concrete way to track progress. Checklists are actionable.

#### 3. Phase Definitions

For each phase:

```markdown
## Phase [N]: [Phase Name]

**Objective**: [What this phase accomplishes - one sentence]

**Actions**:
1. [Specific action with expected input/output]
2. [Specific action with expected input/output]
3. [Specific action with expected input/output]
[...]

**Output**: [What this phase produces]

**Validation Checkpoint**:
- [ ] [Specific check]
- [ ] [Specific check]
- [ ] [Specific check]

**Questions to Ask User** (optional):
- "[When should AI ask this question]"
- "[When clarification is needed]"
```

**Why each subsection matters**:
- **Objective**: Answers "why am I doing this phase?"
- **Actions**: Concrete steps, not vague guidance
- **Output**: Validates the phase produced something
- **Validation Checkpoint**: Explicit go/no-go decision point
- **Questions to Ask User**: When AI should pause and ask for input

#### 4. Success Criteria (End of Document)
```markdown
## Success Criteria

[Pattern name] is complete when:
- ✅ [Measurable criterion]
- ✅ [Measurable criterion]
- ✅ [Measurable criterion]
```

**Why**: Clear definition of "done". Prevents phases from continuing indefinitely.

### Optional Sections

#### Adaptation Notes
```markdown
## Adaptation Notes

This pattern can be adapted for:
- **[Use case 1]**: Replace [concept A] with [concept B], [concept C] with [concept D]
- **[Use case 2]**: Replace [concept A] with [concept E], [concept C] with [concept F]

The core pattern ([high-level structure]) applies broadly.
```

**When to include**: When the pattern is highly reusable across different domains.

#### Common Mistakes to Avoid
```markdown
## Common Mistakes to Avoid

**DON'T**:
- [Anti-pattern 1 and why it's wrong]
- [Anti-pattern 2 and why it's wrong]

**DO**:
- [Correct approach 1]
- [Correct approach 2]
```

**When to include**: When there are known failure modes or common misunderstandings.

---

## Writing Guidelines

### 1. Be Specific in Actions
❌ **Bad**: "Analyze the data"
✅ **Good**: "Read each file in the input/ directory, note the structure and key fields"

### 2. Make Validation Checkpoints Concrete
❌ **Bad**: "Ensure quality is good"
✅ **Good**: 
- [ ] All required fields are present
- [ ] No duplicate entries found
- [ ] Format matches expected structure

### 3. Describe Outputs Clearly
❌ **Bad**: "Results from analysis"
✅ **Good**: "List of 3-7 themes with source references for each"

### 4. Include Stopping Conditions
Each phase should have clear criteria for when to stop and move to the next phase.

### 5. Assume No Prior Context
AI reading PHASES.md might not have seen the full conversation. Make each phase self-explanatory.

### 6. Use Active Voice
❌ **Passive**: "The data should be validated"
✅ **Active**: "Validate the data against the schema"

### 7. Number Actions, Bullet Checkpoints
- Actions are sequential → numbered list
- Validation checks can be done in any order → bullet checkpoints

---

## Phase Count Guidelines

**How many phases should a skill have?**

| Complexity | Typical Phase Count | Example |
|------------|---------------------|---------|
| Simple | 2-3 phases | Read → Process → Output |
| Medium | 4-5 phases | Intake → Analyze → Synthesize → Format → Validate |
| Complex | 6-8 phases | Detailed multi-step analysis with multiple validation points |
| Very Complex | 9+ phases | Consider if this should be multiple skills instead |

**Red flag**: If you have 10+ phases, ask:
- Are some phases actually sub-steps that should be combined?
- Should this be split into multiple skills?
- Is the pattern too specific (not actually reusable)?

---

## Examples of Good vs Bad Structure

### Bad Example (Too Vague)
```markdown
## Phase 1: Setup
Do the initial setup work.

## Phase 2: Processing
Process the data.

## Phase 3: Finish
Complete the task.
```

**Problems**: No concrete actions, no validation, no clear outputs.

### Good Example (Specific and Actionable)
```markdown
## Phase 1: Load Source Files

**Objective**: Identify and load all source files for processing.

**Actions**:
1. List all .csv files in the input/ directory
2. For each file, check it's readable and non-empty
3. Load the header row to identify columns
4. Create an index of files with their column structures

**Output**: Index of all files with metadata (path, row count, columns)

**Validation Checkpoint**:
- [ ] At least one file found
- [ ] All files are readable
- [ ] No files are corrupted or empty
- [ ] Column names are consistent across files (or inconsistencies are noted)

**Questions to Ask User**:
- "I found [N] files. Should I process all of them or exclude some?"
- "Files have different columns: [list]. Should I only process common columns?"
```

**Why this works**: Concrete actions, clear output, measurable checkpoints, knows when to ask questions.

---

## Integration with Other Skill Files

### PHASES.md + README.md
- **README.md**: What the pattern is, when to use it
- **PHASES.md**: How to execute the pattern (detailed steps)

### PHASES.md + PROMPTS.md
- **PHASES.md**: Structure and logic of the workflow
- **PROMPTS.md**: Actual text templates AI should use at each phase

They should reference each other but not duplicate content.

---

## Maintenance

PHASES.md should be updated when:
- Pattern is applied and reveals missing steps
- Validation checkpoints prove insufficient
- Common questions emerge that should be documented
- Phase order proves suboptimal

Don't update for every single use case - only when the PATTERN needs refinement.

---

## Quick Reference Template

```markdown
# [Skill Name] - Pattern Structure

**Note on Phase Count**: This example uses [N] phases. Adapt to your needs — simpler workflows may need fewer, complex ones may need more.

---

## Progress Tracking

\```
Progress:
- [ ] Phase 1: [Name]
- [ ] Phase 2: [Name]
\```

---

## Phase 1: [Name]

**Objective**: [One sentence goal]

**Actions**:
1. [Action with input/output]
2. [Action with input/output]

**Output**: [What this produces]

**Validation Checkpoint**:
- [ ] [Check 1]
- [ ] [Check 2]

**Questions to Ask User** (if applicable):
- "[Question 1]"

---

[Repeat for each phase]

---

## Success Criteria

Pattern is complete when:
- ✅ [Criterion 1]
- ✅ [Criterion 2]

---

**Version**: 1.0
**Pattern Type**: [e.g., Multi-step analysis, Iterative processing, etc.]
**Complexity**: [Simple/Medium/Complex]
```

---

**Version**: 1.1
**Last Updated**: 2026-07-03
**Purpose**: Guide for creating PHASES.md files in skills
