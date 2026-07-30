# Discovery and Requirements Pipeline

**Purpose**: Guidance on the upstream process — how to get from raw project artifacts to structured context docs that agents can use effectively.

---

## Intake Sources

Raw artifacts that feed the discovery pipeline:

- Meeting recordings and transcripts (Teams, Granola, etc.)
- Legacy codebase (mine for requirements, regex patterns, validation rules, field formats)
- Existing documentation — including informal artifacts like whiteboard photos
- Slack messages, JIRA tickets, and other unstructured inputs

---

## Three Requirements Layers

Always extract and separate requirements into these three layers. Do not mix them.

1. **Business requirements** — user journeys, process needs, what the business wants to accomplish
2. **Functional requirements** — data formats, system behaviors, validation rules, field constraints
3. **Technical requirements** — cloud platform, architectural constraints, integration points

Keeping these separate prevents functional requirements from being buried in narrative and technical requirements from driving business decisions.

---

## Legacy Code Mining

Instead of chasing stakeholders for input format requirements, mine the legacy codebase directly.

Example: exact regex strings for field validation are already in the code. This can replace hours of stakeholder chasing and is more reliable than stakeholder recall.

What to look for:
- Validation logic (regex, type checks, range checks)
- Data transformation rules
- Error messages (reveal expected vs. actual behavior)
- Field naming conventions
- Configuration values

---

## Transcript Pre-Processing

Raw transcripts from Teams/Copilot/Granola are not reliable input. Common failures:

- Terminology gets misheard (e.g., "FACS" transcribed as "fax")
- Names are sometimes invented or misattributed
- Industry terms are missed or garbled

**Pre-processing approach**:

1. Do not trust raw transcript notes as-is
2. Feed transcript into a processing session alongside your glossary and participant names
3. Run a sanity check prompt: flag anything that does not make sense, cross-reference against known terms
4. Add slide decks or screenshots at relevant timestamps for additional context
5. Build and maintain your domain glossary over time — it directly improves transcript processing quality

---

## Domain Glossary

Every engagement has a domain glossary — an accumulating list of project-specific terms, acronyms, and entity names. It starts incomplete.

- One old meeting recording can surface missing terms in an hour
- Feed those terms into your AI context so agents understand industry terminology
- Agents without domain context will misinterpret or hallucinate around unfamiliar terms

Treat the glossary as a living document. Any time an agent misreads a term, add it.

---

## ADR Generation

After any meeting where a decision is made, prompt the agent to generate a first-draft ADR (Architecture Decision Record). Do not build from scratch.

Provide: the meeting transcript or notes, the decision that was made, and any alternatives that were discussed. The agent can draft the ADR structure; a human reviews it.

This prevents decisions from living only in meeting notes that are never consulted again.

---

## Backlog Generation Flow

```
Raw artifacts (transcripts, legacy code, Slack)
  → Pre-process and clean
  → Extract three requirements layers
  → Generate PRD
  → Generate epics top-down (cohesive epics → stories → acceptance criteria)
  → Mine acceptance criteria from transcripts and legacy code
  → Use lifecycle hooks to check: "Is this acceptance criteria actually testable?"
  → Result: workable backlog with fewer refinement sessions needed
```

**Note on waterfall risk**: Doing lots of upfront discovery can feel like waterfall. The goal is a better starting point, not a locked plan. Blend upfront context richness with iterative development cycles.

---

**Version**: 1.0
**Last Updated**: 2026-07-03
