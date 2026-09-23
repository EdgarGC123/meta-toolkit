# Plugin: Requirements Writer

**Pattern**: Prompts-only
**Invocation type**: On-demand
**Status**: Starter — adapt to your team's requirements format (user stories, functional specs, BRD sections, etc.)

---

## What It Does

Converts rough descriptions, meeting notes, or stakeholder input into structured requirements. The starter prompt produces user stories with acceptance criteria — override `{{OUTPUT_FORMAT}}` for other formats (functional spec, BRD section, etc.).

## When to Use

- After a discovery or requirements meeting
- When a stakeholder has described what they need in prose and you need it structured
- Before backlog creation — structured requirements are much easier to decompose into stories

## Starting Point Prompt

See `prompts/generate.prompt.md`. The default output is user stories. If your team uses a different format, update the prompt's output section — that's the only part that needs changing.
