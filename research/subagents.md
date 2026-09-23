# Claude Code Subagents — Research Reference

**Research date**: 2026-08-21
**Confidence**: **High.** Frontmatter, discovery, tool scoping, model resolution, and context behavior are traced to the live official docs, fetched four times this session including anchor-targeted passes. Real-world cost and failure-mode evidence is traced to three Anthropic-published engineering writeups, each re-fetched and verified independently. Two named gaps remain (see Gaps), and several unverifiable community claims were excluded on purpose — that exclusion is documented rather than silent.
**TODO reference**: Subagent Generation (G2)
**Purpose**: Confirm the exact `.claude/agents/*.md` contract so `/start-here` Phase 4 can ask one discovery question about specialized roles and Phase 7 can generate starter agent files that actually load and run.

---

## Key Finding

A subagent is a Markdown file with YAML frontmatter in `.claude/agents/`; **only `name` and `description` are required**, and the field set is far larger than the four fields currently documented in `AGENTIC-PATTERNS.md` — there are **17 supported frontmatter fields**, including `effort`, `permissionMode`, `maxTurns`, `skills`, `memory`, `isolation`, and `disallowedTools`.

Two things the generator must act on:

1. **A syntax error is already in the repo.** The `tools` field accepts exact tool names and MCP server patterns only — **`Bash(pytest *)`-style argument specifiers are NOT valid there**, and an unresolvable entry makes the subagent refuse to launch. The QE-agent example currently in `.meta/AGENTIC-PATTERNS.md` would produce a broken agent file.
2. **Subagents are expensive and the vendor's own evidence bounds where they pay.** Anthropic measures agents at "about 4× more tokens than chat interactions" and multi-agent systems at "about 15×" [5], and states plainly that "for a small job it's just overhead" [6]. Their published win (+90.2% over a single agent) is on *breadth-first research*; their published caution is that coding tasks have "fewer truly parallelizable tasks" and that shared-context work "is not a good fit" [5]. So Phase 7 should generate **few** agents, scoped to verbose read-only work — not a menu of roles.

---

## Findings

### 1. Complete frontmatter field reference

**CONFIRMED [1]** — "The following fields can be used in the YAML frontmatter. Only `name` and `description` are required."

| Field | Required | Value / behavior |
|---|---|---|
| `name` | **Yes** | Unique identifier, lowercase letters and hyphens. Hooks receive it as `agent_type`. Filename does not have to match. Cannot contain `:` (reserved for plugin-scoped ids like `my-plugin:reviewer`); a file with `:` in the name is not loaded and the error goes to the debug log. Cannot start with `-`. |
| `description` | **Yes** | When Claude should delegate to this subagent. This is the delegation trigger. |
| `tools` | No | Tools the subagent can use. **If omitted, inherits every tool available to subagents.** If no entry resolves to a real tool, the subagent usually fails to launch with an error naming the entries. Do not list `Skill` to preload skills — use `skills`. |
| `disallowedTools` | No | Denylist; removed from the inherited or specified list. **Note the camelCase** — skills use `disallowed-tools`, agents use `disallowedTools`. |
| `model` | No | `sonnet`, `opus`, `haiku`, `fable`, a full model ID (e.g. `claude-opus-5`), or `inherit`. **Defaults to `inherit`.** |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`, or `manual` (alias for `default`, v2.1.200+). Ignored for plugin subagents. There is no `permissions` frontmatter field. |
| `maxTurns` | No | Max agentic turns before the subagent stops. |
| `skills` | No | Skills preloaded into context at startup — **full skill content is injected, not just the description**. The subagent can still invoke unlisted skills via the `Skill` tool. |
| `mcpServers` | No | Either a server name referencing an already-configured server, or an inline definition (same schema as `.mcp.json`, supports `stdio`, `http`, `sse`, `ws`). Inline servers connect on start, disconnect on finish, and keep their tool descriptions out of the main conversation's context. Ignored for plugin subagents. |
| `hooks` | No | Lifecycle hooks scoped to this subagent (`PreToolUse`, `PostToolUse`, `Stop` → converted to `SubagentStop` at runtime). Ignored for plugin subagents. |
| `memory` | No | `user`, `project`, or `local`. Enables cross-session learning. |
| `background` | No | `true` keeps the subagent in the background even when Claude asks for foreground. |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, `max` — available levels depend on the model. Overrides session effort. Defaults to inheriting from session. |
| `isolation` | No | `worktree` runs the subagent in a temporary git worktree branched from the default branch (not the parent's `HEAD`). Auto-cleaned if no changes. |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` — display color in task list and transcript. |
| `initialPrompt` | No | Auto-submitted as the first user turn when the agent runs as the *main* session agent (`--agent` or the `agent` setting). Prepended to any user-provided prompt. |

**CONFIRMED [1]** — the answer to the suspected-field questions: `effort` **exists**; `disallowed-tools` does **not** (it is `disallowedTools`); there is **no** `permissions` field (it is `permissionMode`).

**CONFIRMED [1]** — Files silently skipped (no session-level report, reason written to the debug log only):
- No `name` → treated as documentation kept beside your agents
- `name` starting with `-` or containing `:` → skipped
- `name` but no `description` → skipped
- YAML that does not parse → skipped

**CONFIRMED [1]** — Validation tooling: `claude plugin validate` can be run against `.claude/agents` or `~/.claude/agents` before a session (requires v2.1.233+). It checks only the named directory and does **not** flag a file whose frontmatter parses but has no `name`. `--debug` surfaces the debug log. `/doctor` reports same-directory name collisions.

**CONFIRMED [1]** — The `/agents` interactive creation wizard was **removed** as of v2.1.198; it now just prints a reminder to ask Claude or edit `.claude/agents/` directly. Relevant to the generator: there is no wizard to defer to, so generating the files is the only path.

### 2. Discovery, scope, and precedence

**CONFIRMED [1]** — Precedence when names collide, highest to lowest:

| Priority | Location | Scope |
|---|---|---|
| 1 | Managed settings `.claude/agents/` | Organization-wide |
| 2 | `--agents` CLI flag (JSON) | Current session only, not saved to disk |
| 3 | `.claude/agents/` | Current project |
| 4 | `~/.claude/agents/` | All your projects |
| 5 | Plugin's `agents/` directory | Where plugin is enabled |

**CONFIRMED [1]** — Additional discovery mechanics:
- Project agents are discovered by **walking up from the CWD**, so every `.claude/agents/` between CWD and repo root is scanned. When nested directories define the same `name`, the definition **closest to the CWD** wins (v2.1.178+).
- Both `.claude/agents/` and `~/.claude/agents/` are scanned **recursively**. Subfolders do not affect identity — identity comes only from the `name` field. (Plugin agents are the exception: `agents/review/security.md` in plugin `my-plugin` registers as `my-plugin:review:security`.)
- Two files in the same tree with the same `name` → only one loads, chosen by **filesystem read order**, not documented precedence.
- `--add-dir` / `/add-dir` directories also load their `.claude/agents/`. **`permissions.additionalDirectories` in settings.json does not** — it grants file access only.
- **Live reload**: Claude Code watches both directories and picks up adds/edits within seconds. Three cases still need a restart: (a) creating a scope's **first** agent file in a directory that did not exist at session start, (b) `.claude/agents/` inside `--add-dir` directories (never watched), (c) sessions started with `--disable-slash-commands`.

**Generator implication (INFERRED)**: A generated toolkit that creates `.claude/agents/` for the first time must tell the user to restart Claude Code. Reasoning: the watcher only covers directories that existed at session start, and `/start-here` creates the directory during the session. Risk if wrong: user reports "Claude can't find my agent" and assumes the generated file is broken.

**CONFIRMED [1]** — Project subagents should be checked into version control so the team can use and improve them collaboratively (stated best practice).

### 3. Delegation and the `description` field

**CONFIRMED [1]** — "Claude uses each subagent's description to decide when to delegate tasks." Automatic delegation is based on three inputs: the task description in the user's request, the `description` field, and current context.

**CONFIRMED [1]** — "To encourage proactive delegation, include phrases like **'use proactively'** in your subagent's `description` field." Both full examples in the docs do exactly this: `"Proactively reviews code... Use immediately after writing or modifying code."` and `"Use proactively when encountering any issues."`

**CONFIRMED [1]** — Three escalating explicit-invocation patterns:
1. **Natural language** — "Use the test-runner subagent to fix failing tests". Claude still decides whether to delegate.
2. **@-mention** — `@"code-reviewer (agent)" look at the auth changes` (manual form `@agent-<name>`). **Guarantees** the subagent runs for one task. Note: it controls *which* subagent, not *what prompt* it receives — Claude still writes the task prompt.
3. **Session-wide** — `claude --agent code-reviewer`, or `{"agent": "code-reviewer"}` in `.claude/settings.json` [2]. The main thread takes on that subagent's system prompt, tool restrictions, and model. **The subagent's system prompt replaces the default Claude Code system prompt entirely** (like `--system-prompt`); CLAUDE.md and project memory still load. Persists across resume. CLI flag overrides the setting.

**CONFIRMED [1]** — Subagents can be disabled per-type via `permissions.deny: ["Agent(Explore)", "Agent(my-custom-agent)"]`, or `--disallowedTools "Agent(Explore)"`. Denying the `Agent` tool itself prevents any delegation.

### 4. Built-in subagents

**CONFIRMED [1]** — Each built-in inherits the parent conversation's permissions; most run with a restricted tool set. **Explore and Plan are the only subagents that skip CLAUDE.md files and the parent session's git status.** Every other built-in and custom subagent loads both, and there is no frontmatter field to change that.

| Agent | Model | Tools | Purpose |
|---|---|---|---|
| `Explore` | Inherits from main conversation, **capped at Opus on the Claude API** (no cap on Bedrock / Google Cloud Agent Platform / Microsoft Foundry / Claude Platform on AWS) | Read-only; Write and Edit denied | File discovery, code search, codebase exploration. Claude passes a thoroughness level: **quick / medium / very thorough** |
| `Plan` | Inherits | Read-only; Write and Edit denied | Codebase research during plan mode |
| `general-purpose` | Inherits | Every tool available to subagents | Complex research, multi-step operations, code modifications |
| `claude` | Inherits | Every tool available to subagents | Catch-all when a task fits no specialized agent; also the default for a dispatched background session |
| `statusline-setup` | Sonnet | — | `/statusline` configuration |
| `claude-code-guide` | Haiku | — | Questions about Claude Code features |

**CONFIRMED [1]** — Important change: as of v2.1.198 `Explore` **inherits the main conversation's model instead of always running on Haiku**. A user or project subagent named `Explore` overrides the built-in and keeps its own `model` field — **define one with `model: haiku` to keep exploration cheap.** This is a concrete, cheap, high-value thing a generated toolkit can ship.

**CONFIRMED [1]** — `Explore` and `Plan` are **one-shot and return no agent ID**, so they cannot be resumed via `SendMessage`. Use `general-purpose` or a custom subagent when follow-up matters.

**CONFIRMED [1]** — Built-ins can be removed: `CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS=1` removes only Explore and Plan (v2.1.198+); `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1` removes all built-in types in non-interactive mode and the Agent SDK. An Agent call omitting `subagent_type` fails with `subagent_type is required` when there is no `general-purpose` fallback.

**When to create a custom subagent instead of using a built-in (CONFIRMED [1], synthesized from the docs' framing)**: "Define a custom subagent when you keep spawning the same kind of worker with the same instructions." Concretely, a custom agent earns its keep when you need any of: a domain-specific system prompt, a tool restriction the built-ins do not give you, a pinned cheaper/more capable model, preloaded skills, persistent `memory`, scoped `hooks`, scoped `mcpServers`, or resumability. If you need none of those, the built-ins (`Explore` for search, `general-purpose` for work) already cover it.

### 5. Tool scoping — the critical detail

**CONFIRMED [1] and [3]** — Resolution rules:
- Neither `tools` nor `disallowedTools` set → inherits every tool available to subagents
- `tools` only → only those listed
- `disallowedTools` only → all parent tools except those
- Both → "`disallowedTools` is applied first, then `tools` is resolved against the remaining pool. A tool listed in both is removed."
- "In every case, the resolved set is limited to the tools available to subagents: a tool that isn't available to subagents is never granted, even when listed in `tools`." [3]

**CONFIRMED [1]** — Two filters narrow the inherited pool. **Forks skip both filters** and receive the main conversation's exact tool pool.

*Filter 1 — removed from every subagent even when listed in `tools`*: `Agent` (when at the depth limit), `AskUserQuestion`, `EndConversation`, `EnterPlanMode`, `ExitPlanMode` (unless `permissionMode: plan`), `ScheduleWakeup`, `TaskOutput`, `WaitForMcpServers`, `Workflow`.

*Filter 2 — background subagents (the default) keep every MCP tool but only these built-ins*: `Read`, `Grep`, `Glob`, `Bash`, `PowerShell`, `Edit`, `Write`, `NotebookEdit`, `WebFetch`, `WebSearch`, `TodoWrite`, `Skill`, `ToolSearch`, `EnterWorktree`, `ExitWorktree`, `Monitor`, `TaskStop`, `SendMessage`, `Artifact`. "Claude Code removes every other built-in tool from a background subagent, whether inherited or listed in the `tools` field, **so the same definition can resolve to different tools in the foreground and the background**."

**Two consequences that matter for generated agent files (INFERRED, high confidence)**:
1. **`AskUserQuestion` is stripped from every subagent.** A subagent cannot ask the user a clarifying question. Reasoning: it is in Filter 1 unconditionally. Risk if wrong: the generator ships an agent whose prompt says "ask the user if unclear" and it silently guesses instead. **Never write "ask the user" into a subagent body — write "state assumptions explicitly in your report" instead.**
2. Listing an exotic tool (e.g. `LSP`, `ReportFindings`) in `tools` for a background subagent is silently useless, and if it is the *only* entry the agent refuses to launch.

**CONFIRMED [1]** — Valid entry forms in `tools` / `disallowedTools`:
- **Exact tool names** — `Read`, `Grep`, `Glob`, `Bash`, `Write`, `Edit`, `WebSearch`, `WebFetch`, ...
- **MCP server-level patterns** — "Both fields accept MCP server-level patterns *in addition to exact tool names*: `mcp__<server>` or `mcp__<server>__*`". In `disallowedTools` only, `mcp__*` removes every MCP tool from any server.
- **`Agent(agent_type)`** — an allowlist of spawnable subagent types, but it "applies **only** to an agent running as the main thread with `claude --agent`. In a subagent definition, listing `Agent` in `tools` lets that subagent spawn subagents of its own while the depth limit allows it, **but any type list inside the parentheses is ignored**."

**CONFIRMED [1]** — **Argument-style permission specifiers are NOT documented as valid `tools` entries.** No example on the page uses them, and unresolved entries do not degrade gracefully: "If no entry in the list resolves to a tool, the subagent usually fails to launch with an error naming the entries." Before v2.1.208 it launched with no tools and returned an empty or confusing result. Argument-style rules (`Bash(npm run *)`, `Read(~/secrets/**)`, `WebFetch(domain:example.com)`) belong to the **permissions system** — `permissions.allow` / `permissions.deny` in settings.json, and `--allowedTools` / `--disallowedTools` [3].

**CONFIRMED [1]** — The documented way to restrict *which Bash commands* a subagent may run is a **`PreToolUse` hook**: "For more dynamic control over tool usage, use `PreToolUse` hooks to validate operations before they execute. This is useful when you need to allow some operations of a tool while blocking others." The hook script reads JSON from stdin and **exits with code 2 to block**. Caveats: the script must be `chmod +x` or "the hook fails instead of blocking anything"; on Windows use `shell: powershell`; and **project-level frontmatter hooks are skipped until the workspace-trust dialog is accepted** (v2.1.218+) — user-level and `--agents` hooks run without trust.

**So there are two correct ways to get a "test-runner that can only run tests"** — pick one, and neither is a `tools:` specifier:
- **Simple / declarative**: `tools: Read, Grep, Glob, Bash` in the agent file, plus `Bash(pytest *)` style rules in `permissions.allow` / `permissions.deny` in `.claude/settings.json` [3]. Caveat: permission rules are session-wide, not per-agent.
- **Per-agent / enforced**: `tools: Bash` plus a frontmatter `PreToolUse` hook running a validator script. Caveat: needs workspace trust and an executable script.

### 6. Model override and cost

**CONFIRMED [1]** — `model` accepts an alias (`sonnet`, `opus`, `haiku`, `fable`), a full model ID (`claude-opus-5`, `claude-sonnet-5` — same values as `--model`), or `inherit`. **Omitting it is the same as `inherit`.** Resolution order:
1. `CLAUDE_CODE_SUBAGENT_MODEL` env var (alias or model ID) — as of v2.1.196, setting it to `inherit` is the same as leaving it unset
2. The per-invocation `model` parameter (also applies when the subagent is resumed or sent a follow-up, v2.1.211+)
3. The subagent definition's `model` frontmatter
4. The main conversation's model

**CONFIRMED [1]** — Values are checked against the org's `availableModels` allowlist [2]. For a blocked family alias, Claude Code runs the newest permitted version of that family (v2.1.222+); otherwise it falls back to the inherited model with a warning in interactive sessions.

**CONFIRMED [1]** — Cost-relevant facts:
- "**Control costs** by routing tasks to faster, cheaper models like Haiku" is listed as one of the five reasons subagents exist.
- **Context window size is set by the subagent's own model, not the parent's.** "Delegating to a model with a smaller window gives that subagent the smaller window."
- Subagents inherit the main conversation's **extended thinking** configuration as of v2.1.198. **There is no per-subagent thinking setting** — but `effort` is per-agent, which is the lever that exists.
- A non-fork subagent has a **separate prompt cache** from the main session; a fork **shares** the main session's cache.

**Generator implication (INFERRED)**: the cheapest reliable win is `model: haiku` on high-volume read-only agents (search, log triage, classification) and `model: inherit` (or omitted) on judgment agents (review, planning). Reasoning: combines the docs' own cost framing with the separate-cache fact — a Haiku subagent's cache misses cost far less than an Opus one's. This is consistent with the existing `BEDROCK-COST-GUIDE.md` "Big Model Plans, Small Model Executes" pattern.

### 7. Context behavior and how results return

**CONFIRMED [1]** — "Each subagent starts with a **fresh, isolated context window**. It doesn't see your conversation history, the skills you've already invoked, or the files Claude has already read. Claude composes a delegation message summarizing the task." The exception is a **fork**, which inherits the parent conversation.

A non-fork subagent's initial context contains:
- **System prompt** — the agent's own body plus environment details Claude Code appends, **not** the full Claude Code system prompt
- **Task message** — the delegation prompt Claude writes
- **CLAUDE.md files** — every level the main conversation loads (`~/.claude/CLAUDE.md`, project rules, `CLAUDE.local.md`, managed policy files). Explore and Plan skip this
- **Git status** — a snapshot from the start of the *parent* session. Absent outside a Git repo or when `includeGitInstructions` is false. Explore and Plan skip it
- **Preloaded skills** — full content of anything in `skills`. Built-in agents do not preload skills
- **Sibling roster** — a system reminder listing `main` and every other *named* agent (v2.1.206+), only when tools include `SendMessage` and at least one other agent has a name; snapshot taken at start

**CONFIRMED [1]** — State that never reaches a non-fork subagent: your **output style**; the main conversation's **auto memory** (use the `memory` field instead); the parent's context window size.

**CONFIRMED [1]** — Results: the subagent "works independently and returns only its final result/summary to the main conversation." A **background** subagent's result arrives as a **completion notification in a later turn**; Claude waits for that notification and reports "still running" if asked earlier (v2.1.211+).

**CONFIRMED [1]** — **No documented byte/token cap on the returned report.** Instead there is output *scanning* (v2.1.210+): Claude Code inspects each final report before Claude reads it. It never removes or rewords anything, but makes two changes — **backslash insertion** into text imitating Claude Code's own output (`<system-reminder>` tags, lines starting `Human:` / `Assistant:`), and a **prepended marker line** starting `[harness: subagent output matched instruction-shaped pattern(s):` when the report imitates such a tag or mentions permission settings like `bypassPermissions` or `--dangerously-skip-permissions`.

**Generator implication (INFERRED)**: the size discipline has to come from the agent's own prompt, since the harness will not truncate for you. Reasoning: no documented cap + the docs' explicit warning that many detailed results consume significant parent context. **Every generated agent body should end with an explicit output contract** ("return at most N bullets", "return file paths and the conclusion, not file contents").

**CONFIRMED [1]** — Other operational facts:
- **Auto-compaction** works in subagents with the same logic as the main conversation; `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` applies. Logged as a `compact_boundary` system entry with `compactMetadata.preTokens`.
- **Transcripts** persist at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`, unaffected by main-conversation compaction, deleted after `cleanupPeriodDays` (30 by default).
- **Resuming**: each invocation creates a new instance; Claude resumes one via `SendMessage` with the agent's ID or name. A completed subagent that receives a `SendMessage` auto-resumes in the background — **unless you stopped it yourself** (v2.1.191+), in which case `SendMessage` returns a refusal.
- **Working directory**: a subagent starts in the main conversation's CWD; `cd` does not persist between Bash calls and does not affect the main conversation's CWD.
- **Nesting depth**: a subagent can spawn subagents up to **three layers** below the main conversation by default. At the limit `Agent` is withheld (in a fork it stays listed but errors). Change with `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`; `1` disables nesting. (History: v2.1.172–216 nested five layers unchangeably; v2.1.217–218 defaulted to one; v2.1.219 raised it to three.) **A fork cannot spawn further forks.**
- **Concurrency**: default limit is **20** running subagents; the 21st fails with `Concurrent subagent limit reached` and the error tells Claude not to retry. Change with `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`. No limit on total subagents over a session. `/subtask` forks take a slot but are never blocked; resuming a finished subagent takes a fresh slot without checking the limit.
- **Permission mode inheritance**: a parent in `bypassPermissions` or `acceptEdits` takes precedence and cannot be overridden by the child. A parent in `auto` mode → the subagent inherits auto mode and **frontmatter `permissionMode` is ignored**. If `permissions.disableBypassPermissionsMode` is set, frontmatter `bypassPermissions` is ignored (v2.1.223+).
- **`memory` requires auto memory to be on** (`autoMemoryEnabled` / `CLAUDE_CODE_DISABLE_AUTO_MEMORY`), otherwise the field has no effect. When enabled, `Read`, `Write`, `Edit` are automatically added, and the first **200 lines or 25KB** of `MEMORY.md` (whichever comes first) is injected with curation instructions. Scopes: `user` → `~/.claude/agent-memory/<name>/`, `project` → `.claude/agent-memory/<name>/`, `local` → `.claude/agent-memory-local/<name>/`. **`project` is the recommended default.**
- **`skills` preloading** cannot load skills with `disable-model-invocation: true`, including the bundled `/verify` skill [4]. Missing or disabled skills are skipped with a debug-log warning.

### 8. Fork vs non-fork subagent

**CONFIRMED [1]**:

| | Fork | Non-fork subagent |
|---|---|---|
| Context | Full conversation history | Fresh context with the prompt passed |
| System prompt and tools | Same as main session | From the definition file, filtered for background runs |
| Model | Same as main session | From the definition's `model` field |
| Permissions | Prompts surface in your terminal | Prompts surface in the main session when backgrounded |
| Prompt cache | Shared with main session | Separate cache |

**CONFIRMED [1]** — Fork mode is **on by default in interactive sessions** (v2.1.232+), off by default in `-p` non-interactive mode and the Agent SDK. Override with `CLAUDE_CODE_FORK_SUBAGENT` (`1` on everywhere, `0` off). To keep fork mode on but stop Claude from spawning forks, deny with an `Agent(fork)` rule. `/subtask` invokes a fork manually (v2.1.212+; `/fork` on v2.1.161–211).

### 9. The competing mechanism the generator must consider: a skill that forks

**CONFIRMED [4]** — A skill can run in its own subagent context via `context: fork`, with `agent:` naming the agent type and `background:` controlling whether the turn waits. "The skill content becomes the prompt that drives the subagent. It won't have access to your conversation history."

**CONFIRMED [4]** — The two directions, verbatim table:

| Approach | System prompt | Task | Also loads |
|---|---|---|---|
| Skill with `context: fork` | From agent type | SKILL.md content | CLAUDE.md, except when the agent is Explore or Plan |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

**CONFIRMED [4]** — Caveats on `context: fork`:
- Warning in the docs: "`context: fork` only makes sense for skills with **explicit instructions**. If your skill contains guidelines like 'use these API conventions' without a task, the subagent receives the guidelines but no actionable prompt, and returns without meaningful output."
- A backgrounded fork "runs with the narrower tool set that applies to background subagents: the skill's subagent is a regular agent type, so the exemption for subagents that fork the conversation doesn't cover it." Set `background: false` to keep the full tool set.
- "A forked skill that runs in the background applies its edits outside your session's checkpoints, so `/rewind` doesn't undo them; use git to revert them."
- Claude Code waits for the result regardless of `background` in `-p` / Agent SDK mode, when `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`, when the same forked skill is already running, or when a scheduled task fires with the skill as its prompt.
- Example given: `name: deep-research`, `context: fork`, `agent: Explore` — "the skill content becomes the task, and the agent provides read-only tools optimized for codebase exploration."

**This is directly load-bearing for G2.** The generator already produces skills (`brief`, `research`, `solution-writer`, `add-checkpoint`). For a role that is really *"run this procedure in isolation and report back"*, adding `context: fork` to an existing generated skill is **strictly less new machinery** than a new agent file. A separate `.claude/agents/` file is warranted when the role needs a distinct **system prompt, tool restriction, pinned model, memory, hooks, or scoped MCP servers** — i.e. an identity, not a procedure.

### 10. Official guidance on when subagents help vs. hurt

**CONFIRMED [1]** — Stated best practices: design focused subagents (each excels at one specific task); write detailed descriptions; limit tool access; check project subagents into version control.

**CONFIRMED [1]** — Use the **main conversation** when:
- The task needs frequent back-and-forth or iterative refinement
- Multiple phases share significant context (planning, implementation, testing)
- You are making a quick, targeted change
- **"Latency matters. A subagent that isn't a fork starts fresh and may need time to gather context"**

**CONFIRMED [1]** — Use a **subagent** when:
- The task produces verbose output you do not need in your main context
- You want to enforce specific tool restrictions or permissions
- The work is self-contained and can return a summary

**CONFIRMED [1]** — Explicit warning: "When subagents complete, their results return to your main conversation. **Running many subagents that each return detailed results can consume significant context.**"

**CONFIRMED [1]** — Scope boundary: "Subagents work within a single session." Parallel independent sessions → background agents. Message-passing between sessions → cross-session messaging. Coordinated supervised team → agent teams. And: "Consider **Skills** instead when you want reusable prompts or workflows that run in the main conversation context. For a question about something already in your conversation, use `/btw` instead of a subagent."

**CONFIRMED [1]** — Documented common patterns (verbatim prompt shapes):
- Isolate high-volume operations — "Use a subagent to run the test suite and report only the failing tests with their error messages"
- Run parallel research — "Research the authentication, database, and API modules in parallel using separate subagents"
- Chain subagents — "Use the code-reviewer subagent to find performance issues, then use the optimizer subagent to fix them"
- Fork the conversation — `/subtask draft unit tests for the parser changes so far`

### 11. Real-world patterns, measured cost, and empirical failure modes

*Every claim in this section was independently re-fetched and verified against the primary URL before inclusion. See "Claims deliberately excluded" at the end of this section.*

**The token overhead is measured and published. CONFIRMED [5]** — Anthropic's own engineering writeup on their multi-agent research system:
- "agents typically use about 4× more tokens than chat interactions"
- "multi-agent systems use about 15× more tokens than chats"
- On BrowseComp, "three factors explained 95% of the performance variance," and "token usage by itself explains 80% of the variance" (the others being tool-call count and model choice)

**Where multi-agent measurably wins. CONFIRMED [5]** — Their system "outperformed single-agent Claude Opus 4 by 90.2% on our internal research eval." Architecture: an "orchestrator-worker pattern" with "Claude Opus 4 as the lead agent and Claude Sonnet 4 subagents," subagents "condensing the most important tokens for the lead research agent," plus a separate CitationAgent for attribution at the end. **The 200,000-token figure in that post refers to the lead agent's context, not a subagent's return size** — there is no published number for how large a subagent's report should be.

**Where multi-agent measurably loses. CONFIRMED [5]** — Domains that "require all agents to share the same context or involve many dependencies between agents are not a good fit." Coding is called out by name: "most coding tasks involve fewer truly parallelizable tasks than research," and agents "aren't yet strong at real-time delegation to one another."

**This is the most important finding for the generator.** The published evidence for multi-agent value comes from *breadth-first research*, and the published caution is specifically about *coding*. A generated toolkit that fans out coding subagents is operating against the vendor's own stated boundary.

**Documented empirical failure modes from Anthropic's own runs:**
- **CONFIRMED [5]** Over-provisioning: early versions were "spawning 50 subagents for simple queries" and endlessly hunted nonexistent sources.
- **CONFIRMED [5]** Vague delegation causes overlap and gaps: "agents duplicate work, leave gaps, or fail to find necessary information." The concrete case given — "one subagent explored the 2021 automotive chip crisis while 2 others duplicated work" on 2025 supply chains. **The described fix is precise task descriptions from the orchestrator**, which is a prompt-quality problem, not an architecture problem.
- **CONFIRMED [7]** Convergent blocking on a monolithic task: 16 agents were set on a Rust C compiler. Where the task split cleanly ("each agent picks a different failing test to work on") parallelism worked. Where it did not — the Linux kernel build — "Every agent would hit the same bug, fix that bug, and then overwrite each other's changes," and "Having 16 agents running didn't help because each was stuck solving the same task." The fix was decomposition, not more agents: using GCC as an "online known-good compiler oracle," a harness that compiled most files with GCC and only the rest with the new compiler, then delta debugging to find file pairs that failed together. Coordination used **file-based locking** — "Claude takes a 'lock' on a task by writing a text file to `current_tasks/`", with git synchronization forcing a second agent to pick a different task. "Merge conflicts are frequent, but Claude is smart enough to figure that out."
- **CONFIRMED [7]** Cost at scale, for calibration: "Opus 4.6 consumed 2 billion input tokens and generated 140 million output tokens, a total cost just under $20,000," across "nearly 2,000 Claude Code sessions across two weeks."

**Practitioner-level guidance from Anthropic's Claude Code session-efficiency writeup. CONFIRMED [6]**:
- What a subagent is for: "The other way to keep something out of your context is to have it happen in a different one." "It runs its own turns, and the only thing that comes back to the main session is its answer."
- When it pays: "It pays off when a job produces a lot of output you don't need to keep, like going through a log." Invocable ad hoc — "go through this log in a subagent."
- **When it does not**: "**For a small job it's just overhead.**"
- The hidden cost: "a subagent sometimes has to re-read things the main session already had," while "paying for its own turns while it does."
- The information cost: "**the main session only gets back what the subagent chose to report.**"
- **Directly endorses the pattern the generator should use**: for repeated noisy jobs, "give it a subagent definition of its own with `model: haiku` (or `sonnet`)". This independently corroborates the cheap-model recommendation in Section 6 from a second source.

**Roles corroborated by primary sources as genuinely useful**: code reviewer with a fresh context that sees only the diff [1]; test-runner that reports only failures [1][7]; log/high-volume-output triage [6]; breadth-first research fan-out with an orchestrator [5]; role specialization on a large codebase — [7] used separate agents for deduplicating code, compiler performance, codegen efficiency, Rust design critique, and documentation.

**Claims deliberately excluded.** The parallel community search returned several confident, plausible-sounding items that **failed verification and are not in this file**:
- A "weak vs. strong description" contrast table, and the claim that "Claude reads only the `description` field — the body is never consulted for that decision," both attributed to the sub-agents docs page. **Four independent fetches of that page (full, `#available-tools`, `#write-effective-descriptions`, and a tail attempt) found no such section and no such sentence.** The real, verifiable guidance is narrower: the description is *one of three* delegation inputs alongside the request and current context [1].
- A "One 'do-everything' agent" anti-patterns list attributed to the same page. Not present; the page has a positively framed best-practices block instead [1].
- Various figures attributed to a "Frontier Red Team" multi-agent study and to named customer deployments. Not verified against a primary URL in this session; treat as unknown rather than true.

*This is itself a finding: the delegation-description topic attracts confident fabrication, including from a Claude-Code-specialist agent. Anyone extending this research should re-fetch before quoting.*

**Documented anti-patterns (all CONFIRMED [1] unless noted)**:
1. **Delegating work that needs iteration.** A non-fork subagent cannot see the conversation and cannot ask questions (`AskUserQuestion` is stripped). Any role requiring back-and-forth belongs in the main conversation. Corroborated by [5]: domains needing shared context or heavy inter-agent dependencies "are not a good fit."
2. **Fan-out with detailed returns.** Many subagents each returning detailed results "can consume significant context" — the exact problem subagents were meant to solve, inverted. And [6]: "the main session only gets back what the subagent chose to report" — so the parent both pays context *and* loses detail.
3. **Latency and cost for small tasks.** A fresh-context subagent "may need time to gather context"; [6] is blunter — "for a small job it's just overhead," and it "sometimes has to re-read things the main session already had" while "paying for its own turns."
4. **Vague `description` or vague delegation prompt** → Claude never delegates, or worse, delegates overlapping work. [5] documents the concrete result: "agents duplicate work, leave gaps, or fail to find necessary information." The docs' fix is a trigger-phrase style description including "use proactively" [1].
4b. **Fanning out on a task that does not actually decompose.** [7]: "Every agent would hit the same bug, fix that bug, and then overwrite each other's changes... Having 16 agents running didn't help because each was stuck solving the same task." The remedy is decomposition (and task-level locking), not agent count.
4c. **Over-provisioning.** [5]: early versions were "spawning 50 subagents for simple queries."
5. **Unresolvable `tools` entries** → the subagent refuses to launch (and on <v2.1.208, launched tool-less and returned confusing output). This is the failure mode a hallucinated `Bash(pytest *)` entry produces.
6. **Silent skips.** A missing `name` or `description`, a `name` containing `:`, or unparseable YAML → the file is skipped with **no session-level report**. A generated agent that never fires may simply never have loaded.
7. **First-file-in-a-new-directory** → not picked up until restart.
8. **Foreground/background tool divergence.** The same definition resolves to different tools depending on how it is run.
9. **Same `name` twice in one tree** → which one loads is filesystem read order.
10. **`isolation: worktree` + commands that reach outside the worktree** → a Bash command whose working directory resolves to the main checkout fails; Claude Code also blocks git redirection into the main checkout and refuses commands whose shape it cannot verify (before v2.1.203 such a command could run in the main checkout).
11. **`bypassPermissions`** skips permission prompts and allows writes to `.git`, `.config/git`, `.claude`, `.vscode`, `.idea`, `.husky`, `.cargo`, `.devcontainer`, `.yarn`, `.mvn`. Never put this in a generated starter file.

---

## Trade-offs and Alternatives

**Three mechanisms, one decision.** For a "specialized role" in a generated toolkit:

| Mechanism | Use when the role is… | Cost |
|---|---|---|
| **Prompt/skill in the main conversation** | A *procedure* that needs the conversation's context and possibly the user's input | Cheapest; pollutes main context with intermediate output |
| **Skill with `context: fork`** [4] | A *procedure* that is self-contained, verbose, and reports back | No new file type; reuses an existing generated skill; but the agent type (and therefore tools/system prompt) is borrowed |
| **`.claude/agents/*.md`** [1] | An *identity* — needs its own system prompt, tool restriction, pinned model, memory, hooks, or scoped MCP servers, and is spawned repeatedly | A new artifact to maintain and version; risks the fan-out/latency problems above |

**Recommendation for G2**: generate agent files **only for roles the user names concretely and that need an identity**, cap the default at 2–3 agents, and default every one of them to a read-only tool set unless the user's described role explicitly requires writes. Reasoning: the docs' own "limit tool access" best practice, plus the fact that over-generation directly triggers documented failure modes 2 and 3. For anything that is really a procedure, prefer `context: fork` on a skill the generator is already producing.

**Contrarian consideration that survived review**: the strongest argument against generating agent files at all is that **the two most valuable roles in a consulting toolkit — research and planning — are already covered better by built-ins and existing generated skills.** `Explore` handles search, `Plan` handles planning research, and the generator already ships a `/research` skill whose whole value is the four-perspective protocol running *in the main conversation* where the user can steer it. Turning `/research` into a subagent would strip `AskUserQuestion` and hide the process from the user — a regression. **This session produced live evidence for that concern**: a specialist subagent was delegated the community-research half of this very question, and it returned confident fabricated quotes attributed to a docs page it had supposedly fetched. Everything usable from it required independent re-verification, so the delegation saved no work on the highest-risk material. That is the failure mode of [6]'s "the main session only gets back what the subagent chose to report," combined with a role that needed judgment the parent could not observe.

This does not defeat G2 — the mechanism is real and the cost math in [5] and [6] shows where it pays. But it means the generator should **ask one narrow question and generate few agents**, favor read-only high-volume roles where the output is verifiable, and never generate an agent for a role whose value depends on unobservable judgment.

---

## Code / Configuration Reference

### Ready-to-use starter: read-only researcher

Every field traced to Source [1]'s field table; tool names traced to Source [3]'s canonical tool table; structure mirrors the docs' own `code-reviewer` example verbatim shape.

```markdown
---
name: doc-researcher
description: Researches external documentation and APIs and reports sourced findings. Use proactively when a task depends on current information about a tool, library, or API that may have changed.
tools: Read, Grep, Glob, WebSearch, WebFetch
model: sonnet
color: blue
---

You are a research specialist. Fetch primary sources before searching. Prefer
official documentation and vendor API references over blog posts.

When invoked:
1. Identify whether an official documentation page answers the question; fetch it first
2. Run at most three additional targeted searches only if the official source is incomplete
3. Trace every factual claim to a URL

You cannot ask clarifying questions. If the request is ambiguous, state the
interpretation you chose at the top of your report and proceed.

Return at most 10 bullets plus a Sources list of URLs. Label each bullet
CONFIRMED (directly stated in a source you fetched) or INFERRED (reasoned,
with the reasoning stated). Do not paste large excerpts — summarize and cite.
```

Field trace: `name`, `description`, `tools`, `model`, `color` — all in the Source [1] field table. `WebSearch` and `WebFetch` are canonical tool names in Source [3] and both survive Filter 2's background allowlist in Source [1]. "Use proactively" is the docs' own recommended delegation phrasing [1]. The "cannot ask clarifying questions" line follows from `AskUserQuestion` being in Filter 1 [1]. The output-size contract follows from the docs' warning that many detailed returns consume parent context [1].

**Companion permission rules** — `WebFetch` and `WebSearch` both require permission [3], so the toolkit's `.claude/settings.json` needs matching entries. Rule syntax traced to Source [3]'s specifier table:

```json
{
  "permissions": {
    "allow": ["WebSearch", "WebFetch(domain:docs.example.com)"]
  }
}
```

### Ready-to-use starter: cheap local Explore override

Traced to Source [1]: "A user or project subagent named `Explore` overrides the built-in and keeps its own `model` field — define one with `model: haiku` to keep exploration cheap."

```markdown
---
name: explore
description: Fast read-only codebase search and file discovery. Use proactively whenever a question requires sweeping many files rather than reading one known file.
tools: Read, Grep, Glob
model: haiku
---

You are a fast codebase search agent. Locate code; do not review or audit it.

Read excerpts rather than whole files. Return absolute file paths with a
one-line note on why each matches, plus a two-sentence conclusion. Never
return file contents beyond the specific lines that matter.
```

**Unverified detail, flagged**: Source [1] refers to the built-in as `Explore` (capitalized) and says a subagent "named `Explore`" overrides it, while the same page requires `name` to use "lowercase letters and hyphens." Whether the override match is case-insensitive is **not stated**. Test this empirically before shipping it in a generated toolkit; if `explore` does not override, the fallback is to name it something else (`fast-search`) and lose the automatic-override benefit.

### Ready-to-use starter: test runner with real Bash scoping

This is the corrected version of the pattern currently mis-documented in `AGENTIC-PATTERNS.md`. Frontmatter hook structure traced verbatim to Source [1]'s `db-reader` example; the exit-2-to-block rule is stated in Source [1].

```markdown
---
name: test-runner
description: Runs the test suite and reports only failures. Use proactively after code changes that could affect tests.
tools: Read, Grep, Glob, Bash
model: haiku
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-test-command.sh"
---

You are a test execution specialist. Run the project's test suite and report
results. Do not modify source files.

Return only: the count of passing and failing tests, and for each failure the
test name, the file path, and the assertion error. Omit stack frames from
library code. Omit passing test output entirely.
```

The validator script pattern, adapted from Source [1]'s verbatim `validate-readonly-query.sh` (same stdin-JSON + `jq` + `exit 2` structure; **the allowlist regex below is this repo's own choice, not from the source — verify it against your project's actual test command**):

```bash
#!/bin/bash
# ./scripts/validate-test-command.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if ! echo "$COMMAND" | grep -qE '^(npm (run )?test|npx (jest|vitest)|pytest|poetry run pytest)\b'; then
  echo "Blocked: this agent may only run the test suite" >&2
  exit 2
fi
exit 0
```

Requires `chmod +x ./scripts/validate-test-command.sh` — Source [1] states the hook "fails instead of blocking anything" if the script is not executable. Also requires accepting the workspace-trust dialog, since this is a project-level frontmatter hook [1].

**Simpler alternative if hooks are too much machinery for a generated toolkit**: drop the `hooks` block entirely and put the scoping in `.claude/settings.json` instead — `"deny": ["Bash(git push *)", "Bash(rm *)"]`, `"allow": ["Bash(npm test *)"]`. Specifier syntax traced to Source [3]. Caveat: those rules apply to the whole session, not just this agent.

### What NOT to write (the hallucination trap)

```markdown
# INVALID — do not generate this
tools: Read, Bash(pytest *), Bash(npm test *)
```

Source [1] documents no argument-style specifiers in `tools`, and states that entries which do not resolve to a tool cause the subagent to fail to launch. This exact line currently appears in `.meta/AGENTIC-PATTERNS.md`.

---

## Gaps and Open Questions

1. **Independent (non-Anthropic) practitioner evidence is thin here.** The cost and failure-mode evidence in Section 11 is all Anthropic-published — Tier 1, but the vendor grading its own mechanism. Not closed: third-party postmortems on agent-file sprawl, and `site:github.com/anthropics/claude-code` issues where delegation silently fails to trigger. A search of those would either corroborate the docs' caveats or surface something the vendor has no incentive to write down.
2. **`Explore` override case-sensitivity** — untested, and the docs are internally ambiguous (see the flag in the starter above). Needs a five-minute empirical test.
3. **Whether `description` has a length cap.** Skills truncate `description` + `when_to_use` at 1,536 characters in the listing [4]; **no equivalent cap is documented for agent `description`**. Do not assume it is unlimited — keep generated descriptions to 1–2 sentences.
4. **No documented size limit on the returned report** was found. If one exists it is undocumented; the practical control is the agent's own output contract.
5. **The tail of the sub-agents page was truncated** by the fetch tool inside the third full example (`data-scientist`). Everything the truncated region would have added is speculative; the two complete examples (`code-reviewer`, `debugger`) plus the patterns section were captured. Re-fetch with an anchor if the `data-scientist` example is needed.
6. **`maxTurns`, `background`, and `initialPrompt` are confirmed to exist but have no worked example** on the page. Do not put them in generated starters without testing.
7. **Interaction between generated agents and the toolkit's permission layers** (`settings.research.json` etc.) has not been designed. An agent whose `tools` include `WebFetch` is useless if the merged settings do not allow the domain.

---

## Contradictions with Prior Knowledge

**`.meta/AGENTIC-PATTERNS.md` contains one invalid syntax claim and two stale ones.** These need fixing as part of G2 — the file is currently the generator's authority on this topic and would propagate the error into every generated toolkit.

1. **INVALID — must fix.** Under "Tool Scoping via Subagents": `A QE subagent: tools: Read, Bash(pytest *), Bash(npm test *) — test runner only`. Source [1] documents no argument-style specifiers in the `tools` field, and unresolved entries cause launch failure. Replace with one of the two correct patterns in the Code Reference above. *This is exactly the fabricated-syntax risk the research request flagged, and it is already in the repo.*
2. **Imprecise.** "`tools` — explicitly list what this agent can use; unlisted tools are denied." True only when `tools` is set. Omitting the field inherits **every** tool available to subagents [1] — the opposite of a deny-by-default. Worth stating explicitly, since an agent file with no `tools` line is the least restricted kind.
3. **Stale.** The description of built-ins does not mention that `Explore` now inherits the main conversation's model (v2.1.198+) rather than always running on Haiku [1], nor that `Explore`/`Plan` skip CLAUDE.md and cannot be resumed. The "define your own `Explore` with `model: haiku`" trick is the actionable replacement.
4. **Incomplete (not wrong).** The four fields listed (`tools`, `model`, `description`, plus `name` in the example) are correct, but 13 more exist. The `effort` and `skills` fields in particular connect directly to the generator's existing `MODEL-BEHAVIOR-RULES.md` and skills library.

**Also relevant**: `AGENTIC-PATTERNS.md`'s hook-event list is narrower than the current catalog — `research/hooks.md` (2026-08-06) already documented this. No conflict between this research and that file; they agree that frontmatter `hooks` support `PreToolUse`, `PostToolUse`, and `Stop`→`SubagentStop`.

**No conflict with any team member's firsthand experience** was identified — no prior statements about subagents were found in project docs beyond `AGENTIC-PATTERNS.md` itself.

---

## Recommended G2 Implementation

Derived from the findings above; not itself sourced.

**Phase 4 question (one question, narrow by design):**
> "Does this workflow have a recurring specialized role — something you'd hand off repeatedly with the same instructions and a deliberately narrow set of tools? If yes, name the role and say what it should and shouldn't be allowed to do. If it's more of a procedure than a role, a skill is the better fit."

Defer as a stub on "not sure / maybe / later", per the existing Phase 4 pattern.

**Phase 7 generation logic:**
0. Apply a scaling rule before generating anything, modeled on [5]'s finding that vague, over-provisioned delegation is the dominant failure: **one agent per named role, and only for roles that produce verbose, verifiable output.** If the described work needs shared context or iterative refinement, generate a skill instead and say why.
1. Generate at most 3 agent files, one per confirmed role, at `.claude/agents/<name>.md`
2. Required frontmatter only plus `tools` and `model`; never `permissionMode: bypassPermissions`
3. Default to read-only (`Read, Grep, Glob`) and add `Bash`, `Edit`, `Write` only when the described role requires it
4. `model: haiku` for high-volume read-only roles; omit `model` (inherit) for judgment roles
5. Every body ends with an explicit output contract and an "you cannot ask clarifying questions — state assumptions" line
6. `description` = 1–2 sentences, third person, ending with a "Use proactively when…" trigger clause
7. Add matching permission entries to the merged `.claude/settings.json` for any permission-requiring tool granted (`Bash`, `Edit`, `Write`, `WebFetch`, `WebSearch`, `Skill`) [3]
8. Note in `GETTING_STARTED.md`: **restart Claude Code once** after generation so the new `.claude/agents/` directory is watched [1]
9. Optionally run `claude plugin validate .claude/agents` as a generation-time check [1]

**Meta Library Map**: add `.claude/agents/` as a conditional resource, with a pointer to the skill-vs-fork-vs-agent decision table above so the generator does not reach for an agent file when `context: fork` on an existing skill would do.

---

## Sources

[1] Create custom subagents — Claude Code docs (fetched 2026-08-21, three passes: full page, `#available-tools` anchor, and a tail attempt that hit a length cap) — https://code.claude.com/docs/en/sub-agents
[2] Claude Code settings reference (fetched 2026-08-21; `agent` key, `availableModels`, `disableAgentView`, `disableSideloadFlags`, agent file scopes) — https://code.claude.com/docs/en/settings
[3] Tools reference — canonical tool names, permission-required column, rule specifier formats, subagent tool-resolution rules (fetched 2026-08-21) — https://code.claude.com/docs/en/tools-reference
[4] Extend Claude with skills — skill frontmatter table, `context: fork` / `agent` / `background`, "Run skills in a subagent" and the skill-vs-subagent comparison table (fetched 2026-08-21) — https://code.claude.com/docs/en/skills
[5] How we built our multi-agent research system — Anthropic Engineering; token multiples (4×/15×), 90.2% eval result, 80%-of-variance finding, poor-fit guidance, 50-subagent and duplicate-work failure modes (fetched and verified 2026-08-21) — https://www.anthropic.com/engineering/multi-agent-research-system
[6] Maximizing the value of your Claude Code sessions — subagent cost/benefit at the practitioner level; "for a small job it's just overhead", re-reading context, "only gets back what the subagent chose to report", `model: haiku` recommendation (fetched and verified 2026-08-21) — https://claude.com/blog/maximizing-the-value-of-your-claude-code-sessions
[7] Building a C compiler with Claude — Anthropic Engineering; 16 parallel agents, convergent-blocking failure, oracle-based decomposition, file-based task locking, token and cost totals (fetched and verified 2026-08-21) — https://www.anthropic.com/engineering/building-c-compiler

**Not used as sources**: a parallel community search returned claims attributed to the sub-agents docs page and to unnamed studies that four independent fetches could not confirm. Those claims are listed and rejected in Section 11 rather than cited.
