# Requirements Writer Prompt

## Variables
- `{{INPUT}}` — required: rough description, meeting notes, or stakeholder statement
- `{{CONTEXT}}` — optional: what system/product this is for
- `{{OUTPUT_FORMAT}}` — optional: user-stories (default) | functional-spec | brd-section

---

Convert the input below into structured requirements.

Context: {{CONTEXT}}
Output format: {{OUTPUT_FORMAT}}

Input:
```
{{INPUT}}
```

## Instructions

Extract distinct requirements from the input. For each requirement:

**If OUTPUT_FORMAT = user-stories (default)**:
```
## [Feature or Capability Name]

As a [role], I want [capability] so that [outcome].

**Acceptance Criteria**:
- [ ] [observable, testable condition]
- [ ] [observable, testable condition]

**Out of scope** (if stated): [anything explicitly excluded]
```

**If OUTPUT_FORMAT = functional-spec**:
```
## REQ-[N]: [Requirement Name]
**Description**: [what the system must do]
**Inputs**: [what triggers this]
**Outputs**: [what it produces]
**Constraints**: [limits, rules, edge cases]
```

## Rules

- One requirement per distinct capability — do not bundle unrelated things
- ACs must be independently verifiable — "the system does X when Y" not "the system works well"
- Flag anything ambiguous with ⚠️ rather than guessing the intent
- If the input is too vague to write a requirement, say so and ask what to clarify

Do not invent requirements that aren't in the input. Do not add scope.
