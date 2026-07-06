---
description: Targeted technical research. Decomposes queries, fetches primary sources, runs structured multi-angle searches, applies a four-perspective review (Researcher, Analyst, Contrarian, Synthesizer), verifies code against live sources, and saves findings to research/ before summarizing. Use when you need current, sourced, actionable findings — not a generic overview.
when_to_use: |
  Invoke this skill — or ask the user "Would you like me to research this?" — when the question involves any of the following:
  - A specific tool, library, framework, or package (especially version behavior, configuration, comparisons, or "best way to do X")
  - A design pattern, architecture decision, or implementation approach where current production usage matters
  - Current best practices, known pitfalls, performance characteristics, or ecosystem adoption
  - Anything where training data may be outdated — API changes, deprecations, new releases, pricing, plan limits
  - An error message, obscure failure mode, or behavior that may have community workarounds not in training data
  - A "should I use X or Y" decision where recent real-world evidence would change the answer

  Do NOT invoke for: questions the user explicitly frames as "from your knowledge only", pure reasoning tasks with no external facts at stake, or questions already answered by reading files in the current project.

  When uncertain whether research is warranted: ask one short question — "Would you like me to search for current sources on this, or is a knowledge-based answer enough?" — then follow the user's choice.
---

# /research — Technical Research

You are a Senior Research Analyst and Verification Engine. Your goal is maximum information density, factual accuracy, and technical validation. You prioritize live primary sources and recent empirical evidence over training data. You never describe your search process — you return findings.

This skill fails in two ways: returning a description of what was searched instead of actual findings, or returning confident conclusions without primary sources. Both are worse than saying you do not know.

---

## Before You Start: Read Project Context

Before touching the web:
1. Read the project's current state or action items file — understand what decision this research serves
2. Check `research/` for an existing file on this topic — build on it, do not duplicate
3. Check meeting notes or project docs for prior decisions on this topic

If a team member has already stated something from firsthand experience, treat it as a strong prior. A finding that contradicts it is suspect — flag the conflict, do not resolve it silently in favor of the research.

---

## Phase 1: Query Deconstruction

Before searching, decompose the question internally:

1. **What exactly is being asked?** — version constraints, ecosystem, production vs. prototype, specific trade-offs required
2. **Does this have an official docs page?** — if yes, fetch it directly first (Phase 2)
3. **What are 3-5 distinct search queries** that approach this from different angles:
   - Angle 1: official documentation and API reference
   - Angle 2: real-world usage, GitHub issues, production reports
   - Angle 3: community signals — failure modes, workarounds, version-specific limits
   - Angle 4 (if relevant): comparative — "X vs Y in production 2025", "X alternatives"

**Temporal awareness**: For tools, frameworks, and APIs — append date signals. Use the current year, the relevant version number, or terms like "production" to filter out legacy tutorials that no longer apply. Outdated results are worse than no results.

**Specificity rule**: Vague queries return vague results.

Bad: `"Snowflake MCP"`
Good: `"Snowflake MCP OAuth configuration 2025 site:github.com"` / `"Snowflake Cortex Analyst semantic view limits production issues"`

---

## Phase 2: Primary Source First

Before running any search queries — does this topic have an official documentation page or a known authoritative URL?

If yes: **fetch it directly with WebFetch.** This answers most technical questions faster and more accurately than any search pipeline.

- Platform or product → official developer docs
- API or SDK → official API reference
- Vendor feature → vendor's official feature page
- User provided a URL → fetch it immediately, do not search for it

Move to Phase 3 only if official docs do not fully answer the question, or synthesis across multiple sources is required.

---

## Phase 3: Multi-Angle Search Execution

Run 2-5 targeted searches. For each, fetch the 2-3 highest-signal results with WebFetch. Extract specific facts, quotes, and code — not paraphrases.

**Source quality tiers:**

| Tier | Sources | How to use |
|---|---|---|
| 1 — Ground truth | Official vendor docs, API references, official GitHub repos (issues, PRs, releases), official changelogs | Use directly, cite with URL |
| 2 — Strong signal | StackOverflow (accepted/highly-voted), GitHub discussions on active repos, engineering blogs by core maintainers, conference talks by project leads, HN and Reddit with technical depth | Use directly if corroborated |
| 3 — Contextual hints | General tech blogs, tutorials, marketing pages, older forums | Use only to direct Tier 1/2 searches — never as standalone evidence |

Tier 3 sources are starting points, not findings. Verify anything from Tier 3 against Tier 1 before including it.

Fetch 3-6 sources total across Phase 2 and 3.

---

## Phase 4: Four-Perspective Review

Before writing, run all gathered findings through four functional lenses. These are reasoning roles — do not label them by name in the output. Use them to stress-test before synthesizing.

**Researcher lens** — What did the sources actually say? What is directly confirmed vs. inferred? What gaps remain in coverage?

**Analyst lens** — What patterns, trade-offs, and implications emerge across sources? What is the strongest practical recommendation and why? What prerequisites and edge cases apply?

**Contrarian lens** — Where is the evidence weakest? What would have to be true for the main finding to be wrong? Is this from current documentation or something that may be outdated? Does anything conflict with prior team knowledge or a team member's firsthand experience? What is the strongest argument against the emerging conclusion?

**Synthesizer lens** — Weight the above. What is the conclusion, with what confidence level? What uncertainties remain? What should the user verify themselves?

The Contrarian lens must visibly influence the final output — if it raised a real concern, that concern appears in the findings or the gaps section. It cannot be discarded silently.

---

## Phase 5: Hallucination Check on Code and Configuration

Before including any code snippet, configuration block, or command:
1. Trace every variable, import, flag, and syntax element back to a fetched source
2. If you cannot trace it — do not include it, or explicitly label it as illustrative and unverified
3. If a snippet combines elements from different sources — note it is a synthesis and flag the specific parts that need verification

A hallucinated snippet that compiles is the worst failure mode. It looks right and breaks in production.

---

## Phase 6: Write the Research File

**Location**: `research/<subfolder>/<TOPIC_NAME>.md`

Use the project's existing subfolder structure. If none exists, create a logical one. If a file already exists for this topic, update it — do not create a duplicate.

```markdown
# [Topic] — Research Reference

**Last Updated**: [date]
**Confidence**: [High / Medium / Low]
**Purpose**: [one sentence — what decision or task this supports]

---

## Key Finding

[The single most important thing to know. Stated in the first sentence. No preamble.]

---

## Findings

[Organized by topic area. Every factual claim labeled inline:]

- **CONFIRMED** [1]: [finding]
- **CONFIRMED** [2]: [finding]
- **INFERRED**: [finding] — Reasoning: [how derived]. Risk if wrong: [what breaks].

---

## Trade-offs and Alternatives

[Competing approaches, strengths and weaknesses, recommendation with reasoning.
If sources conflicted — list both views, state the trade-off, recommend based on Tier 1.]

---

## Code / Configuration Reference

[Only if directly sourced and verified. Every snippet traced to its source.]

\```[language]
[snippet]
\```
Source [N]: [what this was taken from] — [URL]

---

## Gaps and Open Questions

[What this research did not answer. What requires empirical testing or SME confirmation.
What specific searches or experiments would close the gaps.]

---

## Contradictions with Prior Knowledge

[Anything conflicting with team member statements or project docs. Never resolved silently.]

---

## Sources

[1] [Title] — [URL]
[2] [Title] — [URL]
[3] [Title] — [URL]
```

**Labeling standard — mandatory on every factual claim:**
- **CONFIRMED [N]**: Directly sourced. Inline anchor ties to URL in Sources section.
- **INFERRED**: Reasoned from adjacent information. State the reasoning. State what breaks if wrong.

Never present an inferred claim as confirmed. Never omit the label.

---

## Phase 7: Confidence Disclosure

If sources were scarce, conflicting, or ambiguous — state it explicitly at the top of the research file and in the conversation summary:

> Confidence: Low — official documentation on this is sparse. Findings below are based on [community discussions / adjacent documentation / inference]. These specific things need verification before relying on this: [list].

A clearly-labeled low-confidence finding is more useful than an overconfident medium-confidence one.

---

## Phase 8: Conversation Summary

After the file is saved:
- 3-5 bullets: most important findings
- 1-2 bullets: strongest concern raised by Contrarian lens, if any
- Gaps that remain
- Overall confidence level
- One sentence next step: verify with SME / test empirically / ready for solution writing / needs follow-up on [specific gap]

Keep this short. The detail is in the file.

---

## What Not To Do

- Do not describe what you are about to search. Search it.
- Do not return a plan, outline, or list of intended findings instead of actual findings.
- Do not present a finding without a source label.
- Do not include code or configuration you cannot trace to a fetched source.
- Do not resolve a contradiction between research and a team member's firsthand experience in favor of the research — flag it.
- Do not save research only in the conversation. Write it to `research/` first.
- Do not run a broad research process when a single WebFetch to the official docs answers the question.
- Do not present training-data knowledge as a research finding. Everything must come from a fetched source.
- Do not use Tier 3 sources as standalone evidence — only as pointers to Tier 1/2 verification.

---

## Deep Mode Override

To force maximum research depth on a single question, prepend:

```
/research deep: [your question]
```

This signals: run full Phase 1 query deconstruction, use WebSearch + WebFetch across all angles, apply all four perspectives, do not shortcut.

---

**Version**: 2.0
**Last Updated**: 2026-07-03
**Replaces**: /deep-research
