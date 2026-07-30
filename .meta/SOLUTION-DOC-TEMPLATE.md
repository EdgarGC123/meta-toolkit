# Solution Doc Template

**When to use**: Create one solution doc per client-facing deliverable or use case. This is a reference template - copy it when needed, do not generate it at bootstrap.

**Location convention**: `docs/[track-name]/solutions/[use-case-name].md`

**Paired with**: A planning doc at `docs/[track-name]/solution_planning/[use-case-name]_PLANNING.md` (internal only, moved to `.archive/` once this doc is finalized)

---

## How to Use This Template

1. Copy the full template below into the appropriate `solutions/` folder
2. Fill in every client-facing section
3. Add internal-only sections at the bottom as needed during development
4. Remove or strip all `> ⚠️ Internal only` sections before client delivery
5. Run the handoff checklist before marking complete

---

---
# [Skill / Deliverable Name]

**Invocation**: `[how the user triggers this - e.g. /skill-name or "Ask Claude to..."]`  
**Use case**: [One sentence — what business problem this solves]  
**Owner**: [Role, not name — e.g. "Engagement lead", "Developer"]  
**Platform**: [Claude Project / Claude for Excel Add-In / Claude Code CLI]  
**Status**: [Draft / In Review / Client-Ready]  
**Last updated**: [YYYY-MM-DD]

---

## What This Does

[2-4 sentences in plain English. What does this skill do, and what is the business value? Avoid technical language. Write for someone who has never used Claude.]

**Time saved**: [Estimated time this replaces — e.g. "Replaces 30-45 minutes of manual Excel work per invoice cycle"]

---

## Before You Use This

[One-time setup or prerequisites the user must complete before the skill will work. If none, write "No setup required."]

- [ ] [Setup step 1]
- [ ] [Setup step 2]

**Platform notes**:
- [Any behavior that differs between desktop and web, or between plan tiers]
- [File access requirements, if applicable]

---

## How to Run

**Prerequisites**:

| Requirement | Details |
|---|---|
| [Input 1] | [Format, location, naming convention] |
| [Input 2] | [Format, location, naming convention] |

**Primary method**:

1. [Step 1]
2. [Step 2]
3. [Step 3]

**Alternative method** (if applicable):

[Describe the alternative and when to use it instead]

---

## Understanding the Output

[What does the user get back? Describe the format, structure, and any important fields.]

**Always appended**:
- [Any standard disclaimer or caveat that appears in every output]
- [e.g. "All figures are based on data provided and have not been independently verified"]

---

## Understanding the Files / Data

[Only include this section if the skill works with structured files or data. Delete if not applicable.]

**File naming convention**: `[pattern — e.g. invoice_YYYY-MM-DD_vendor.xlsx]`

**Key fields**:

| Field | Description | Notes |
|---|---|---|
| [Column/field name] | [What it contains] | [Edge cases or formatting notes] |

---

## Skill Behavior — What Claude Does Automatically

This section describes the automatic behaviors the skill performs without being asked.
Write it in plain language — end users will rely on it to understand why Claude behaves the way it does.

Cover:
- Environment detection (e.g. desktop vs web, file present vs missing)
- How missing or ambiguous inputs are handled
- What the skill confirms before executing
- How errors are surfaced and what the user should do

Keep it factual and specific. Avoid "Claude will try to..." — state what it actually does.

---

- **Environment detection**: [e.g. "Detects whether you are on desktop or web Excel and adjusts behavior accordingly"]
- **Missing input handling**: [e.g. "If the date range is not specified, asks before proceeding"]
- **Confirmation before running**: [e.g. "Always confirms what file was found and what will happen before executing"]
- **Error handling**: [e.g. "If the required file is missing, states the exact filename needed and stops — it does not proceed with guessed inputs"]

---

## Creating the Skill

Use these three fields when creating the skill in Claude Projects or the Excel Add-In:

**Field 1 - Name**: `[skill-name]`

**Field 2 - Description** (trigger language):
```
[Write as the sentence a user would say. Example: "When the user wants to analyze
invoice data and flag overdue items above a threshold, run this skill."]
```

**Field 3 - Instructions** (full prompt):
```
[Paste the complete, self-sufficient skill prompt here. Must follow the required
prompt structure: identity sentence, PRE-FLIGHT block with communication rule,
numbered STEP checks, data reference, analysis logic, output format.]
```

---

## Scope

**In scope**:
- [What this skill covers]

**Out of scope**:
- [What this skill does not do]

**Future consideration**:
- [Enhancements that are possible but not built — link to planning doc for details]

---

## Data Lineage

[Only include if relevant — e.g. for financial or compliance-sensitive outputs. Delete if not applicable.]

| Stage | Source | Transformation |
|---|---|---|
| Input | [Where data comes from] | [How it arrives] |
| Processing | [What the skill does to it] | [Rules applied] |
| Output | [What gets returned] | [Format, rounding, filters] |

---

> ⚠️ Internal only - remove before client delivery
>
> ## Test Examples
>
> [Sample inputs and expected outputs used during development. Include edge cases.]
>
> | Input | Expected output | Notes |
> |---|---|---|
> | [Test case 1] | [Expected result] | [Edge case notes] |
>
> ---
>
> ## Drawbacks
>
> [Known limitations, edge cases where the skill underperforms, or conditions where
> a manual approach might be better. Honest assessment for internal use.]
>
> ---
>
> ## Alternate Solutions
>
> [Other approaches considered and why this one was chosen. Useful if scope changes.]
>
> ---
>
> ## Open Items
>
> Open items live in the planning doc, not here. See:
> `docs/[track-name]/solution_planning/[use-case-name]_PLANNING.md`

---

## Handoff Checklist

Before marking this document client-ready:

- [ ] All `> ⚠️ Internal only` sections removed
- [ ] No personal names in forward-looking instructions (use roles)
- [ ] No references to internal Slack channels, internal URLs, or internal systems
- [ ] Reviewed by at least one team member other than the builder
- [ ] Three-field creation block complete and tested end-to-end
- [ ] Setup instructions verified by someone other than the builder
- [ ] Platform noted and any desktop/web differences documented
- [ ] Planning doc moved to `.archive/` if work is finalized

---

**Template version**: 1.0  
**Last updated**: 2026-06-17
