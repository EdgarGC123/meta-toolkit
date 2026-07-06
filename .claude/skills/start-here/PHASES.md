# Start Here — Phase Structure and Branching Logic

The toolkit generation process is adaptive. Phase 1 determines what questions are relevant in all subsequent phases. Do not ask questions that the context has already ruled out. Accept "I don't know yet" on any question and handle it as a deferred stub.

---

## Meta Library Map — What's Available to Pull From

Before generating anything, understand what the generator provides. Every file in `.meta/` is a potential input to generation. Read this map at the start of Phase 0 and use it throughout Phases 4 and 7.

### Always copied into every generated toolkit
| Resource | Source | Destination |
|---|---|---|
| `AI_BEHAVIOR_GUIDELINES.md` | `.meta/AI_BEHAVIOR_GUIDELINES.md` | toolkit root |
| Base permission layer | `.meta/settings.template.json` | `.claude/settings.json` (as starting point) |
| `/brief` skill | `.meta/base-skills/brief/` | `.claude/skills/brief/` |
| `/research` skill | `.meta/base-skills/research/` | `.claude/skills/research/` |
| `/solution-writer` skill | `.meta/base-skills/solution-writer/` | `.claude/skills/solution-writer/` |

### Conditionally included — copy based on discovery answers
| Resource | Source | Condition |
|---|---|---|
| Reference skills | `.meta/skills/[name]/` | User selects or skill matches workflow pattern |
| Plugins | `.meta/plugins/[name]/` | User selects or plugin matches workflow need |
| Output templates | `.meta/templates/[name]/` | User requests consistent output format |
| Research permission layer | `.meta/settings.research.json` | Toolkit needs web search or doc fetching |
| Developer permission layer | `.meta/settings.developer.json` | Toolkit involves writing/deploying code |
| Diagnostic permission layer | `.meta/settings.diagnostic.json` | Toolkit involves infrastructure inspection |

### Reference only — consulted during generation, not copied
| Resource | Use during generation |
|---|---|
| `ARCHITECTURE.md` | Understand the system being built; folder conventions |
| `SKILL_GUIDE.md` | Skill structure, A-J build sequence, platform decision matrix |
| `PLUGIN_GUIDE.md` | Plugin structure and patterns |
| `PHASES_GUIDE.md` | How to write PHASES.md for generated skills |
| `PROMPTS_GUIDE.md` | How to write PROMPTS.md for generated skills |
| `AGENTIC_PATTERNS.md` | Reusable agentic workflow patterns to recommend |
| `PROMPT_ENGINEERING.md` | Prompt design principles to bake into WORKFLOW.md |
| `DISCOVERY_PIPELINE.md` | Requirements extraction guidance for research/discovery toolkits |
| `MODEL_SELECTION.md` | Model guidance to include in CLAUDE.md if relevant |
| `SOLUTION_DOC_TEMPLATE.md` | Template structure for client-facing deliverables |
| `MEETING_NOTES_TEMPLATE.md` | Meeting notes format for `reference/meetings/` |
| `PERMISSIONS_TEMPLATE_README.md` | How to merge permission layers into `settings.json` |
| `TESTING_GUIDE.md` | Testing structure guidance when code involvement confirmed |
| `CLAUDE_CODE_SKILLS_REFERENCE.md` | Frontmatter fields and discovery rules for skills |

**Rule**: A generated toolkit should never be a blank skeleton. Every relevant `.meta/` resource should either be copied in, referenced in context docs, or explicitly deferred. If a resource is relevant and neither copied nor deferred, it was missed.

---

## Phase 0: Pre-Flight

Before starting, silently verify:
- Working directory contains the generator structure (`.meta/`, `.claude/skills/start-here/`)
- If not: hard stop — "This skill must be run from the ai-toolkit-accelerator directory."

**Immediately kick off the git detach subagent in the background** — do this before announcing anything to the user. The subagent runs concurrently while the discovery conversation proceeds and the user never waits for it.

Subagent instructions (pass verbatim — do not paraphrase or expand):

```
You have one job: remove the .git directory from the current working directory.

Steps:
1. Run: rm -rf .git
2. Verify .git no longer exists by running: ls -la .git
3. If verification confirms .git is gone: return the single word SUCCESS
4. If .git did not exist to begin with: return the single word SUCCESS
5. If rm fails or .git still exists after removal: return FAILED followed by the error or ls output
```

Subagent configuration:
- `allowed-tools: Bash(rm -rf .git), Bash(ls *)` — no other tools
- `context: fork` — isolated context, does not affect main conversation

**How to handle the subagent result in Phase 8:**

When Phase 8 runs, check whether the subagent returned a result:

**Case 1 — Subagent returned SUCCESS:**
Include this line in the completion message (natural, not alarming):
> "Git history and remote connection removed. This toolkit is clean — run `git init` when you're ready to start your own repository."

**Case 2 — Subagent returned FAILED or no result was received:**
Do not wait or retry during the conversation. At Phase 8, verify the state yourself by running `ls -la .git` directly.
- If `.git` is gone: treat as SUCCESS and include the note above.
- If `.git` still exists: attempt `rm -rf .git` once yourself. Re-verify with `ls -la .git`.
  - If now gone: include the SUCCESS note above.
  - If still present: include this warning in the completion message instead:
> "⚠️ Git detach incomplete — .git still exists in this directory. Your toolkit is otherwise ready, but it remains connected to the generator's remote repository. Run `rm -rf .git` manually, then `git init` to start fresh."

Announce in one line: "Starting toolkit generation. I'll ask a short set of discovery questions, then go deeper based on what you share."

---

## Phase 1: Discovery Intake

**Goal**: Surface the signals that determine which questions matter. Keep this tight — 4-5 questions maximum. Do not ask for the full workflow description yet.

Ask these questions, one at a time, waiting for each answer before continuing:

**Q1: Who is this toolkit for?**
- You personally (solo workflow)
- Your team (internal shared use)
- A client engagement (external delivery)
- Not sure yet

*Branches to:*
- Solo → lightweight path, Section B of SKILL_GUIDE sensibility, fewer confirmation gates
- Team/Client → full path with tracks, delivery platform, internal/client separation, handoff checklist

**Q2: What is the primary output — what does "done" look like for one complete run of this toolkit?**
Free text. A sentence or two. This anchors all phase and success-criteria questions later.

**Q3: Does this involve writing, reviewing, or deploying code?**
- Yes
- No
- Possibly / not sure yet

*Branches to:*
- Yes → architecture conventions checklist before phase design, test framework question, PR size guardrails
- No → skip all code-related questions
- Possibly → defer as stub (see Deferred Stubs section)

**Q4: Does this involve client-facing deliverables — documents, reports, presentations the client will receive?**
- Yes
- No
- Possibly / not sure yet

*Branches to:*
- Yes → delivery platform question, internal/client separation, solution doc pattern, handoff checklist
- No → skip delivery platform and separation questions
- Possibly → defer as stub

**Q5: Does the work span multiple independent workstreams or tracks?**
- Yes
- No
- Not sure yet

*Branches to:*
- Yes → ask for track names, generate per-track folder structure in docs/ and research/
- No → single docs/ and research/ at root
- Not sure → single structure with a note on how to expand to multi-track later

---

## Phase 2: Workflow Description

Now ask for the workflow description. Context from Phase 1 shapes the prompt — do not give a generic "describe your agent" prompt; reference what was shared.

Example prompt shape (adapt based on Phase 1 answers):
> "Based on what you've shared — [restate 2-3 key signals from Phase 1] — describe the workflow in more detail. What does the agent do step by step? What inputs does it start with? What does it produce?"

Accept file references: `file:path/to/description.txt`

After receiving the description:
1. Detect workflow type from the description: analysis / creation / processing / decision
2. Propose a phase structure (names and objectives only — not sub-steps yet)
3. Present recommendations with brief reasoning
4. Ask for confirmation or adjustments before proceeding

---

## Phase 3: Phase Design

For each confirmed phase, ask in sequence:

1. **Objective** — one sentence: what does this phase accomplish?
2. **Inputs** — what does this phase start with? (files, prior phase output, user input)
3. **Sub-steps** — what are the concrete actions? (comma-separated or numbered)
4. **Success signal** — how does the agent know this phase is done?
5. **Questions the agent should ask** — what does it need to clarify before running?

Keep this efficient. If the user answers Q1 in a way that makes Q3 or Q4 self-evident, skip them and confirm: "I'll infer the sub-steps from your objective — correct?"

---

## Phase 4: Follow-On Questions

Based on what emerged in Phases 1-3, go deeper on anything that determines what gets built. Use the Meta Library Map above — every conditional resource in that table corresponds to something to ask about here.

**The general pattern for each topic:**
1. Ask what you need to know to build it well
2. If the answer is clear: incorporate it into the generation plan
3. If the answer is "not sure / maybe / later": defer as stub — do not ask follow-up questions on it, do not block generation

**Topics to always cover in Phase 4** (adapt the question to context — don't read these as a script):

**Permissions / what the agent is allowed to do:**
Ask what the toolkit's agent will need to access. Map answers to the permission templates in `.meta/`:
- Needs to search the web, fetch documentation, call external APIs → include `settings.research.json`
- Needs to write/commit code, run tests, deploy to cloud → include `settings.developer.json`
- Needs to inspect infrastructure, run diagnostics, read cloud state → include `settings.diagnostic.json`
- Needs none of the above → base template only (`settings.template.json`)
- Not sure → defer as stub; generate with base template only and note in `.deferred/permissions.md`

The final `settings.json` is produced by merging the base layer with any additional layers. See `.meta/PERMISSIONS_TEMPLATE_README.md` for merge rules.

**Skills and plugins available:**
Review what's in `.meta/skills/` and `.meta/plugins/`. For each:
- Does this workflow pattern match something already built? → offer to include it
- Does the user describe a need that maps to a plugin capability? → offer it
- Not sure → skip; the user can add later via `/toolkit-advisor`

**Output templates:**
Does the toolkit produce repeatable artifacts (reports, summaries, solution docs)? If yes → offer to include output templates from `.meta/templates/`. If not yet — defer.

**Agentic workflow patterns:**
Does the workflow involve multi-agent orchestration, iterative loops, TDD, or backlog generation? If yes → reference the relevant pattern from `.meta/AGENTIC_PATTERNS.md` in the generated WORKFLOW.md so the user has it as a starting point.

**Reference material for WORKFLOW.md:**
Based on what the toolkit does, decide which `.meta/` reference docs to surface in the generated toolkit's WORKFLOW.md or CLAUDE.md:
- Discovery/research heavy → pull from `DISCOVERY_PIPELINE.md`
- Client deliverables → reference `SOLUTION_DOC_TEMPLATE.md`
- Model selection matters → include relevant section from `MODEL_SELECTION.md`
- Prompt engineering is core to the workflow → reference `PROMPT_ENGINEERING.md`

**Other topics that may surface** (illustrations, not a checklist):
- How work is structured across the engagement (tracks, ownership)
- Conventions the team follows (code, naming, review gates)
- Integrations and tools already in play
- What the success signal is for the engagement overall

Read the signals from Phase 1 and ask only what's relevant. A solo personal workflow does not need delivery platform or permissions questions beyond the base template. A pure documentation workflow does not need architecture convention questions. When in doubt: one short framing question to find out, then decide whether to go deeper or defer.

---

## Phase 5: Surface Unknowns

Before generating, do a single pass over all "possibly / not sure yet" answers from Phases 1-4.

For each unknown, confirm with the user:
> "[Topic X] was marked as not yet known. I'll create a deferred stub for it — a placeholder that explains what to build and what questions to answer when you're ready to expand it. Is that right, or do you want to answer now?"

This keeps the conversation moving without forcing premature decisions.

---

## Phase 6: Final Confirmation

Present the full structure summary (see PROMPTS.md for format). Include a "Deferred Stubs" section listing any topics being parked for later.

Ask: "Ready to generate?" Allow modifications before proceeding.

---

## Phase 7: Generate

Create all files. Reference PROMPTS.md for progress messaging format. Use the Meta Library Map to verify nothing was missed before closing.

**Always generated:**
1. Directory structure (docs/, research/, reference/meetings/, .claude/skills/)
2. CLAUDE.md (session guide with dynamic provenance paragraph)
3. README.md
4. GETTING_STARTED.md
5. workflow/WORKFLOW.md — embed relevant agentic patterns, prompt engineering principles, and discovery pipeline guidance as appropriate for this toolkit's workflow type
6. workflow/CONFIG.md
7. AI_BEHAVIOR_GUIDELINES.md (copy from `.meta/AI_BEHAVIOR_GUIDELINES.md`)
8. .claude/settings.json — **always created.** Start with `settings.template.json` as the base. Merge in any additional permission layers confirmed in Phase 4 (research, developer, diagnostic). If none were confirmed, the file still gets created with the base layer only. See `.meta/PERMISSIONS_TEMPLATE_README.md` for merge rules.

**Base skills — always copied from `.meta/base-skills/`:**
9. .claude/skills/brief/
10. .claude/skills/research/
11. .claude/skills/solution-writer/

**Starter documents — empty templates with structure:**
12. docs/ACTION_ITEMS.md
13. docs/PROJECT_CONTEXT.md
14. reference/meetings/MEETING_NOTES_SUMMARY.md — use `.meta/MEETING_NOTES_TEMPLATE.md` as the format reference

**Conditional — only if selected or confirmed during Phase 4:**
15. Skills from `.meta/skills/` → copy selected ones to `skills/` at toolkit root
16. Plugins from `.meta/plugins/` → copy selected ones to `plugins/` at toolkit root
17. Templates from `.meta/templates/` → copy selected ones to `templates/` at toolkit root
18. Testing structure — if code involvement confirmed, use `.meta/TESTING_GUIDE.md` as reference
19. Path-scoped rules, validation hooks — if requested

**Deferred:**
20. `.deferred/[topic].md` for any "not sure yet" answers — always include a reference to the relevant `.meta/` guide in the stub so the user knows where to look when expanding

**Before closing Phase 7 — verify against Meta Library Map:**
- Every conditional resource in the map is either included, explicitly skipped, or deferred
- `.claude/settings.json` exists (always — even if only the base layer was needed)
- WORKFLOW.md references any relevant patterns from `AGENTIC_PATTERNS.md` or `PROMPT_ENGINEERING.md`
- CLAUDE.md provenance section lists everything active in this toolkit

---

## Phase 8: Clean Up and Close

**Step 1 — Check git detach result** (before anything else):
Resolve the subagent outcome from Phase 0 per the handling rules defined there. Determine which completion note applies (success line or warning). Do not skip this even if the conversation ran long — the git state check is a single `ls -la .git` command.

**Step 2 — Delete scaffolding:**
- `bootstrap.py` and `bootstrap.py.backup` (if present from older versions of the generator)
- `.claude/skills/start-here/` (this skill — it has done its job)
- `.meta/` directory (all guides, base-skills source templates, accumulation folders)
- `START_HERE.md`

The generated toolkit's `.claude/skills/` now contains only the base skills copied during generation (brief, research, solution-writer). The `.meta/` deletion does not affect them — they were already copied to their destination.

**Step 3 — Validate and report:**
Verify all required files exist. Report completion with a summary of what was generated and what was deferred. Include the git detach note (success or warning) as determined in Step 1.

---

## Deferred Stubs Protocol

Any time a user answers "not sure," "maybe," "possibly," or "later" — on *any* topic — generate a stub. This applies universally: no topic is too small or too large to defer. The stub is always the same structure, regardless of what the topic is.

Create `.deferred/[topic-name].md`:

```markdown
# Deferred: [Topic Name]

**Status**: Not yet implemented — expand when ready

## What this would add

[2-3 sentences: what would be built if this were confirmed, and why it matters]

## Questions to answer first

- [The question that was deferred]
- [Any sub-questions that would naturally follow from the answer]
- [Continue until the shape of what needs to be built would be clear]

## How to expand

When ready, describe the need in a new session. The process will:
1. Walk through the questions above
2. Run `/research` for current patterns, examples, and best practices if useful
3. Generate the component and integrate it into the existing toolkit

## Reference

- See `DESIGN_PHILOSOPHY.md` in the AI Toolkit Generator for design rationale
- See `.meta/` guides in the generator if still available
```

Keep stub filenames short and descriptive: `testing.md`, `delivery-platform.md`, `track-structure.md`, `integrations.md` — whatever names the topic clearly.

Stubs are listed in the CLAUDE.md "About This Toolkit" section so they surface at the start of every session.

---

## Handling Expansion Requests (Post-Generation)

If a user returns with a deferred topic — "we do have unit tests now, here's the framework" — the pattern is:

1. Read the relevant `.deferred/[topic].md` stub
2. Run the same discovery questions listed in the stub
3. If patterns/best practices/examples would help: invoke `/research` with a focused query before generating
4. Generate the component
5. Integrate into the existing toolkit (update WORKFLOW.md, CLAUDE.md provenance section, any affected skills)
6. Delete the stub once complete

This is the same process whether the user is starting from the original accelerator or working from a generated toolkit that still has `.meta/` available via `/toolkit-advisor`.

---

**Version**: 2.0
**Last Updated**: 2026-07-03
