# Claude Model Configuration — Cost and Behavior Reference

**Research date**: 2026-08-21
**Confidence**: High on pricing mechanics and cache invalidation (all Tier 1, quoted from official docs). Low on per-effort-level cost deltas — Anthropic does not publish them, and the one available number is explicitly disclaimed as illustrative.
**TODO reference**: "Verify Bedrock/model claims from Gemini research session" and "Model tier research"
**Purpose**: Replace the Gemini-sourced numbers in `.meta/MODEL-SELECTION.md` (Tactical Usage Guide) and `.meta/BEDROCK-COST-GUIDE.md` with verified figures, so generated toolkits give users correct cost guidance.

---

## Key Finding

**Effort level and model choice are cache-keyed settings, not just quality dials — changing either mid-session forces a full uncached re-read of the entire conversation, and that is the dominant cost mechanic in an interactive session.** Of the seven questions asked, five are now confirmed to High confidence from official docs, one is **refuted** (there is no >200K token pricing premium on current models), and one is **not documented at all** (there are no published cost deltas per effort level; anyone quoting them is guessing).

Three claims in the current project docs are wrong and must be corrected: the 200K context surcharge, the "~2 reads" cache break-even, and the framing of `high` effort as "extended thinking enabled."

---

## Findings

### 1. Effort levels — what they actually change

- **CONFIRMED** [1]: Five levels exist: `low`, `medium`, `high`, `xhigh`, `max`. Set at `output_config.effort` — **inside `output_config`, not top-level**, and not inside the `thinking` object [4]. GA, no beta header.
- **CONFIRMED** [1]: **Effort affects all tokens in the response, not just thinking.** Quoting: "The effort parameter affects **all tokens** in the response, including: Text responses and explanations; Tool calls and function arguments; Thinking (when active)." Two stated advantages: "It doesn't require thinking to be enabled" and "It can affect all token spend including tool calls."
- **CONFIRMED** [1]: At lower effort, Claude tends to "Combine multiple operations into fewer tool calls / Make fewer tool calls / Proceed directly to action without preamble / Use terse confirmation messages." Higher effort makes more tool calls and explains plans first. **In an agentic harness this tool-call multiplier is the real cost driver, more than thinking depth.**
- **CONFIRMED** [1]: It is **not a token budget**. Quoting: "Effort is a behavioral signal, not a strict token budget. At lower effort levels, Claude will still think on sufficiently difficult problems, but it will think less than it would at higher effort levels for the same problem."
- **CONFIRMED** [1]: API default is `high` on every supported model, and `high` is byte-identical in behavior to omitting the parameter: "Setting `effort` to `"high"` produces exactly the same behavior as omitting the `effort` parameter entirely."
- **CONFIRMED** [4]: Per-level thinking behavior — `max`: "always thinks with no constraints on thinking depth"; `xhigh`: "always thinks deeply with extended exploration"; `high`: "almost always thinks"; `medium`: "moderate thinking. May skip thinking for simple queries"; `low`: "minimizes thinking. Skips thinking for simple tasks."
- **CONFIRMED** [1]: The scale is **calibrated per model** — "the same level name does not represent the same underlying value across models" [6]. Anthropic's guidance is to re-run an effort sweep on evals when changing models, not to carry a level over.
- **CONFIRMED** [1]: Level availability is not uniform. `max` is on Fable 5, Mythos 5, Opus 5, 4.8, Mythos Preview, 4.7, 4.6, Sonnet 5, Sonnet 4.6. `xhigh` is on Fable 5, Mythos 5, Opus 5, 4.8, 4.7, Sonnet 5 — **not** Opus 4.6 or Sonnet 4.6. Opus 4.5 supports `low`/`medium`/`high` only.
- **CONFIRMED** [1]: On Opus 5, "changing effort does not reliably shorten responses, so prompt for length instead." Effort controls thinking volume, not visible verbosity, on that model.
- **CONFIRMED** [1]: On Opus 5, `thinking: {"type": "disabled"}` returns a **400** at `xhigh` or `max` effort.

#### Claude Code defaults and controls (differ from the API in one place)

- **CONFIRMED** [6]: "The default effort is `high` on every model that supports effort, **except Opus 4.7, which defaults to `xhigh`**." This matches the API default except for Opus 4.7.
- **CONFIRMED** [6]: Claude Code level support: Fable 5 / Opus 5 / Sonnet 5 / Opus 4.8 / Opus 4.7 → `low, medium, high, xhigh, max`. Opus 4.6 / Sonnet 4.6 → `low, medium, high, max`.
- **CONFIRMED** [6]: Unsupported levels degrade silently downward: "Claude Code falls back to the highest supported level at or below the one you set. For example, `xhigh` runs as `high` on Opus 4.6."
- **CONFIRMED** [6]: Precedence — `CLAUDE_CODE_EFFORT_LEVEL` env var > configured level > model default. Skill/subagent frontmatter `effort` overrides the session level but **not** the env var.
- **CONFIRMED** [6]: `max` and `ultracode` are **session-only** and are not accepted in the `effortLevel` settings key. `low`/`medium`/`high`/`xhigh` persist across sessions.
- **CONFIRMED** [6]: `ultracode` is **not a model effort level** — it is a Claude Code setting that "sends `xhigh` to the model and additionally has Claude orchestrate dynamic workflows for substantive tasks." Budget for it as `xhigh` plus orchestration overhead.
- **CONFIRMED** [6]: `ultrathink` in a prompt "adds an in-context instruction. **The effort level sent to the API is unchanged.**" Other phrases ("think hard", "think more") are passed through as ordinary text and are **not** recognized as keywords. This corrects a widespread community belief.
- **CONFIRMED** [6]: Enterprise admins can cap effort per model per role ("Organization effort limits"). Above-cap requests run at the cap; with `json`/`stream-json` output or in background agents "the clamp applies silently."

#### The real cost delta between effort levels — NOT DOCUMENTED

- **CONFIRMED** [9]: Anthropic publishes **no** per-level cost or token multipliers. The only quantified figure found anywhere is a figure caption in Anthropic's own blog: "The high effort path generates roughly **7x** more tokens to reach a higher confidence answer." This is one prompt, one comparison, and the same article explicitly disclaims its cost/quality curves as "for illustration purposes only" and "do not represent real benchmark data."
- **INFERRED**: There is no stable per-level multiplier to publish, because effort changes tool-call count and response length as well as thinking — so the multiplier is workload-shaped, not model-shaped. Reasoning: [1] states effort affects all token categories including tool calls, and [1] states "The impact of effort levels varies by task type." Risk if wrong: none material; the practical guidance (measure on your own workload) is the same either way.
- **Actionable consequence**: the generator must not print a cost table per effort level. It should tell users to measure with `/usage` and `usage.output_tokens_details.thinking_tokens`, and treat `~7x low→high on a reasoning-heavy prompt` as a loose upper-bound anecdote, not a planning number.

### 2. Fast mode

- **CONFIRMED** [5]: **It is not a different model.** Quoting: "Fast mode is not a different model. It uses Claude Opus with a different API configuration that prioritizes speed over cost efficiency. **You get identical quality and capabilities with faster responses.**" There is no quality tradeoff to reason about — only latency vs price.
- **CONFIRMED** [5]: Up to **2.5x faster**. Supported on **Opus 5 and Opus 4.8 only**. Not on Sonnet, Haiku, or any other model.
- **CONFIRMED** [2][5]: Pricing is **$10 / MTok input, $50 / MTok output** on both Opus 5 and Opus 4.8 — exactly **2x** standard Opus ($5 / $25). Same rate card as Fable 5, on an Opus-capability model.
- **CONFIRMED** [2][5]: "Fast mode pricing applies across the full context window, including requests over 200k input tokens" — flat, no long-context tier.
- **CONFIRMED** [2][5]: **Claude API (first-party) and Claude subscriptions only.** Explicitly **not available** on Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, or Claude Platform on AWS. Also not available with the Batch API. **For any Bedrock-based toolkit, fast mode is simply out of scope.**
- **CONFIRMED** [5]: Prompt caching multipliers and the data-residency multiplier **stack on top of** fast mode pricing [2].
- **CONFIRMED** [5]: On subscription plans, fast mode "draws directly from usage credits, even if you have remaining usage on your plan" and is "not included in the subscription rate limits."
- **CONFIRMED** [5]: Separate rate limit pool shared across all supported Opus models. On hitting it, fast mode auto-falls back to standard speed and re-enables after cooldown.
- **CONFIRMED** [5]: Opus 5 is the fast-mode default in Claude Code v2.1.219+. Enabling fast mode from a non-Opus model auto-switches you to Opus (which is itself a cache invalidation — see below).
- **CONFIRMED** [5][7]: **When it is worth using** — "interactive work where response latency matters more than cost": rapid iteration, live debugging, tight deadlines. **Not** worth it for "long autonomous tasks where speed matters less, batch processing or CI/CD pipelines, cost-sensitive workloads."
- **CONFIRMED** [5]: Fast mode vs lower effort are orthogonal and combinable: "**Fast mode**: Same model quality, lower latency, higher cost. **Lower effort level**: Less thinking time, faster responses, potentially lower quality on complex tasks."

### 3. Extended thinking — billing

- **CONFIRMED** [4]: **Thinking tokens are billed as output tokens.** Thinking incurs charges for: "Tokens Claude uses while thinking (billed as output tokens)"; prior-turn thinking blocks that remain in context (**billed as input tokens**); and standard text output.
- **CONFIRMED** [4]: **The `display` setting does not change what you pay.** "What you're billed for is the same regardless of the `display` setting; only what you see changes." Under `display: "omitted"` (the default on Fable 5 / Mythos 5 / Opus 5 / 4.8 / 4.7 / Sonnet 5) you are billed for "the full thinking tokens Claude generated internally" while seeing zero. Explicit warning: "The billed output token count does **not** match the visible token count in the response."
- **CONFIRMED** [6]: Same in Claude Code: "You are charged for all thinking tokens generated, even when collapsed or redacted."
- **CONFIRMED** [4]: **There is no thinking budget per effort level, and no thinking budget to set at all on current models.** "You don't set a thinking token budget. Two controls bound cost: `max_tokens` is a hard cap on total output for the request, thinking and response text combined... `effort` is soft guidance on how much of that output Claude allocates to thinking. It shapes behavior but doesn't guarantee a token count."
- **CONFIRMED** [4]: In a tool-use loop, "each request in the turn has its own `max_tokens`, so it doesn't bound the whole turn's spend." `max_tokens` is not a session cost cap.
- **CONFIRMED** [8]: Thinking blocks from prior turns are **kept by default** on Opus 4.5+, Sonnet 4.6+, Fable 5, Mythos 5, Mythos Preview — and therefore re-billed as input tokens on every subsequent request. On earlier Opus/Sonnet and **all Haiku models** they are stripped automatically. This is a real, under-appreciated cost difference between tiers.
- **CONFIRMED** [4]: Observability field: `usage.output_tokens_details.thinking_tokens`, "always less than or equal to `output_tokens`." When streaming, appears only on the final `message_delta` event.
- **CONFIRMED** [7]: Claude Code guidance: "Extended thinking is enabled by default... Thinking tokens are billed as output tokens, and **the default budget can be tens of thousands of tokens per request depending on the model.**"
- **CONFIRMED** [6]: `MAX_THINKING_TOKENS=0` turns thinking off on the Anthropic API **except on Fable 5**. Nonzero values apply only under a fixed thinking budget, which only Opus 4.6 / Sonnet 4.6 can revert to via `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`. "Adaptive-reasoning models ignore nonzero budgets, so use effort levels there instead" [7]. **Thinking cannot be turned off on Fable 5** at all.

### 4. Setting interactions — is low effort on a big model better than high effort on a small one?

- **CONFIRMED** [9]: **There is no documented crossover point, and Anthropic explicitly declines to rank them.** Quoting the blog: "**None of these is universally better.**" Model ≈ "how capable"; effort ≈ "how thorough."
- **CONFIRMED** [9]: The stated decision rule is diagnostic, not numeric — ask whether Claude "did it not *try* hard enough, or did it not *know* enough?"
  - **Raise the model** when context was sufficient and it still failed: "if Claude clearly tried and still got it wrong, that's a signal to pick a larger model." Also for subtle bugs, unfamiliar domains, architecture calls, and ambiguity.
  - **Raise effort** for *process* failures: "skipping a file, not running the tests, or not double-checking its work."
  - **Check context first**: "if you're raising effort on work that shouldn't need it, the fix is often upstream, in your context, your CLAUDE.md, or how the task is scoped."
- **CONFIRMED** [9]: Two economic statements that cut in opposite directions:
  - **Routine work** → downshift the model: both sizes usually succeed at equal effort, the larger one just adds verification at a higher per-token price, so downshifting "saves real money at no quality cost."
  - **Hard multi-step work** → upshift the model: the smaller model burns iterations, so "the total cost per task can come out lower" on the larger model — and it can do tasks the smaller one cannot "even at the highest effort settings."
- **CONFIRMED** [9]: On Fable 5 for long-horizon agentic work: in internal testing "it finished jobs Opus and Sonnet can't reach at any effort level," but it "costs the most per token."
- **CONFIRMED** [9]: Effort is meant to be a **standing preference**, not a per-task dial: "Consider this more as a general preference than a task-by-task decision." This aligns with the caching constraint — see §5.
- **CONFIRMED** [1]: Anthropic's own model-level guidance implies rough equivalences but only one is stated numerically-adjacent: on Sonnet 5, "**Medium effort:** Cost-saving step-down from the default. **Comparable to Claude Sonnet 4.6 at high effort.**" That is the closest thing to a documented crossover in the corpus. Also [1]: "Lower effort settings on Claude Fable 5 still perform well and **often exceed `xhigh` performance on prior models**."
- **INFERRED**: Cost-optimal practice is to pick the model by capability need and then hold effort constant for the session, rather than trading the two off. Reasoning: effort deltas are unmeasurable in advance ([1]: "The impact of effort levels varies by task type"), and varying effort within a session carries a certain, quantifiable cache penalty ([3], §5). Risk if wrong: a user leaves effort higher than needed and overpays on routine work — mitigated by setting the level once at session start.

### 5. Prompt caching — multipliers and invalidation

All CONFIRMED from [2] and [3], quoted verbatim.

| Cache operation | Multiplier | Duration |
|---|---|---|
| 5-minute cache write | **1.25x** base input price | Cache valid for 5 minutes |
| 1-hour cache write | **2x** base input price | Cache valid for 1 hour |
| Cache read (hit) | **0.1x** base input price | Same duration as the preceding write |

- **CONFIRMED** [2]: **Break-even is one read at 5-minute TTL, two reads at 1-hour TTL** — "caching pays off after **one** cache read for the 5-minute duration (1.25x write), or after **two** cache reads for the 1-hour duration (2x write)." **This corrects `BEDROCK-COST-GUIDE.md`, which states "approximately 2 reads" for the general case.**
- **CONFIRMED** [3]: Cache refreshes on hit are **free**: "The cache is refreshed for no additional cost each time the cached content is used."
- **CONFIRMED** [2]: Cache multipliers "stack with other pricing modifiers such as the Batch API discount and data residency" — and with fast mode pricing [2].
- **CONFIRMED** [3]: TTL is measured **from the start of the request** that writes or reads the entry — response generation time counts against it.
- **CONFIRMED** [3]: Minimum cacheable prefix, and it is **not monotonic across generations**:

| Minimum | Models |
|---:|---|
| 512 tokens | Opus 5, Fable 5, Mythos 5 |
| 1,024 tokens | Opus 4.8, Sonnet 5, Sonnet 4.6, Sonnet 4.5 |
| 2,048 tokens | Opus 4.7, Mythos Preview |
| 4,096 tokens | Opus 4.6, Opus 4.5, **Haiku 4.5** |

  Below the minimum, caching **fails silently** — no error, `cache_creation_input_tokens` and `cache_read_input_tokens` both 0. Haiku 4.5 needing 4,096 tokens is a trap for small-prompt high-volume work.

#### The three specific invalidation questions asked

- **Does switching model invalidate? YES.** **CONFIRMED** [3] (Claude Code, stated plainly): "**Model**: each model has its own cache. Switching models recomputes the entire request even when the content is identical." Also: "Switching with `/model` means the next request reads the entire conversation history with no cache hits, even though the content is identical."
  - **Caveat worth flagging**: the *API* prompt-caching page has **no row for model switch** in its invalidation table and no prose statement about it. The claim is fully documented on the Claude Code side [3] and implied by the per-model minimums on the API side, but the API page itself does not say it. For API-level work, treat model-scoping as High confidence via the Claude Code doc, not via the API doc.
- **Does changing effort level invalidate? YES — with one exception.** **CONFIRMED** [3][4]: the API invalidation table has an explicit **"Effort setting"** row: "Changing `output_config.effort` always invalidates message blocks, same model-specific effect on tool/system caches as thinking parameters. **Setting effort explicitly to the model's default is equivalent to omitting it and does not invalidate.**" [4] adds: "The resolved effort value is rendered into the prompt." Claude Code [3]: "The cache is keyed by effort level as well as model, so switching with `/effort` means the next request reads the entire conversation history with no cache hits."
  - Anthropic ships a **runnable demonstration** with real usage numbers [4]: turn 1 `cache_creation_input_tokens: 3546, cache_read_input_tokens: 0`; turn 2 (same config) `cache_creation: 0, cache_read: 3546`; turn 3 (effort changed `high`→`medium`) `cache_creation: 3546, cache_read: 0`.
  - **Direct guidance** [1]: "**Hold effort constant within cached conversations**... vary effort across workloads rather than within a conversation that relies on cache hits."
- **Does enabling fast mode invalidate? YES, once per conversation.** **CONFIRMED** [3]: "Enabling fast mode adds a request header that is part of the cache key, so the next request reads the entire conversation history with no cache hits. **Those uncached input tokens are billed at fast mode rates**, which is why turning it on at the start of a session costs less than turning it on deep into a long one." And: "**The cost applies once per conversation.** After the first fast mode turn, Claude Code keeps sending the header and varies only the request's speed setting, which is not part of the cache key. Turning fast mode off... and turning it back on later all keep the cache."
  - **Source conflict — flagged, not resolved**: the API prompt-caching table [3] lists a **"Speed setting"** row stating that "Switching between `speed: "fast"` and standard speed invalidates system and message caches" (tools ✓, system ✘, messages ✘). The Claude Code page says the speed setting "is not part of the cache key" once the header is being sent persistently. These are in direct tension. Practical reading: the *header* is the cache key component, and Claude Code works around the API-level behavior by sending the header continuously. Do not assume toggling `speed` is free at the raw API layer.

#### Full Claude Code invalidation ledger — CONFIRMED [3]

**Invalidates (one slower, more expensive turn):** switching models; changing effort level; turning on fast mode; connecting/disconnecting an MCP server *whose tools load into the prefix*; enabling/disabling a plugin *that provides prefix-loaded MCP servers*; adding a **bare** tool-name deny rule (`Bash`, `WebFetch`, `Bash(*)`, `"*"`); `/compact`; upgrading Claude Code. Resuming a session after an upgrade "reprocesses the entire conversation history with no cache hits" and "the first turn back into a long session can be the most expensive request you send."

**Keeps the cache (safe mid-task):** editing files in your repo; editing CLAUDE.md mid-session (but the edit also **doesn't apply** until `/clear`, `/compact`, or restart); changing output style (same — doesn't apply); changing permission mode (except `opusplan`, which switches model on plan-mode toggle); invoking skills and commands (injected as user messages); `/recap`; `/rewind`; spawning a subagent. Scoped deny rules like `Bash(rm *)` and **all** allow/ask rules are prefix-safe.

**Notable specifics:**
- **CONFIRMED** [3]: MCP tools are **deferred by default** on supported models, so ordinary server connect/disconnect churn is cache-safe. Invalidation only happens where tool search is unavailable/disabled, or for `alwaysLoad` servers.
- **CONFIRMED** [3]: `opusplan` makes **every plan-mode toggle a model switch** and a fresh cache.
- **CONFIRMED** [3]: `/clear` "costs nothing"; `/compact` "is itself a large request" but reads the warm prefix from cache, so mid-session it "costs a fraction of what the context size suggests." After a break longer than the TTL, `/compact` reprocesses the full history uncached — the worst case. `/rewind` "truncates back to a prefix that is already cached," so it is cheaper than `/compact` for abandoning a path.
- **CONFIRMED** [3]: **Cache scope in Claude Code is effectively one machine + one directory** — "The system prompt embeds the working directory, platform, shell, OS version, and auto memory paths, so two sessions in different directories build different prefixes and miss each other's cache. That includes worktrees of the same repository." Sequential sessions in the same directory share the prefix **only when the git status snapshot at startup matches**, since the system prompt also captures branch and recent commits.
- **CONFIRMED** [3]: **Subagents get their own cache and use the 5-minute TTL even on a subscription.** A **fork** inherits the parent's system prompt, tools, and history exactly, so its first request *does* read the parent's cache.
- **CONFIRMED** [3]: 20-block lookback — "The system checks at most 20 positions per breakpoint." Long agentic turns with many tool_use/tool_result pairs can silently blow past it.
- **CONFIRMED** [3]: Concurrency — "a cache entry only becomes available after the first response begins." N parallel identical requests all pay full price.

#### Claude Code cache TTL defaults — CONFIRMED [3]

| Auth path | Default TTL |
|---|---|
| Claude subscription (Pro/Max/Team/Enterprise) | **1 hour**, requested automatically |
| Subscription, but drawing on usage credits | **drops to 5 minutes** automatically (1h writes cost more) |
| API key, Amazon Bedrock, Google Cloud Agent Platform, Microsoft Foundry, Claude Platform on AWS | **5 minutes** |

Overrides: `ENABLE_PROMPT_CACHING_1H=1` to opt into 1 hour; `FORCE_PROMPT_CACHING_5M=1` to force 5 minutes regardless of auth. Disable entirely with `DISABLE_PROMPT_CACHING` (or per-family `DISABLE_PROMPT_CACHING_{HAIKU,SONNET,OPUS,FABLE}`).

### 6. Context window cost behavior beyond 200K — REFUTED

- **CONFIRMED** [2]: **There is no long-context pricing multiplier on current models.** Quoting the pricing page's "Long context pricing" section in full: "Claude 4.6 and later models and Claude Mythos Preview include the full 1M token context window **at standard pricing**. (**A 900k-token request is billed at the same per-token rate as a 9k-token request.**) Prompt caching and batch processing discounts apply at standard rates across the full context window."
- **CONFIRMED** [8]: "For every model with a 1M-token context window, 1M is the default: you don't need a beta header, and long-context requests are billed at standard pricing."
- **CONFIRMED** [2]: Fast mode is also flat: "Fast mode pricing applies across the full context window, including requests over 200k input tokens."
- **The Gemini-sourced "2x billing multiplier beyond 200K tokens" in `BEDROCK-COST-GUIDE.md` is refuted for all current models and must be deleted.**
- **INFERRED**: The claim likely originated from the older Sonnet 4 / 4.5 1M-context **beta**, which did carry a long-context premium tier. Reasoning: the pricing page scopes the standard-pricing statement to "Claude 4.6 and later," implying earlier 1M offerings were priced differently. Risk if wrong: none for current guidance; matters only if a toolkit pins Sonnet 4.5 with 1M context. **What would confirm it**: the Bedrock or Vertex pricing page, or a docs changelog entry for the Sonnet 4 1M beta. Not verified here.

### 7. Other settings that materially change cost

- **CONFIRMED** [2]: **The 4.7+ tokenizer inflates token counts ~30%.** "Claude 4.7 and later models and Claude Mythos Preview use a newer tokenizer... This tokenizer produces **approximately 30% more tokens for the same text.** The exact increase depends on the content and workload shape. Claude Sonnet 4.6 and earlier models use the previous tokenizer." **This is the single most under-appreciated cost finding here.** Sonnet 5 at $2/MTok vs Sonnet 4.6 at $3/MTok is a smaller real saving than the headline suggests, and Opus 4.7/4.8/5 and Fable 5 all cost ~30% more tokens for identical text than Sonnet 4.6. Any cross-generation cost comparison must re-baseline with the token-counting API.
- **CONFIRMED** [2]: **Sonnet 5 is now permanently $2 / $10.** "The $2/$10 per million input/output token pricing for Claude Sonnet 5, announced at launch as introductory pricing through August 31, 2026, **is now the standard price.** The previously scheduled increase to $3/$15 per million input/output tokens on September 1, 2026 **will not occur.**" This resolves an ambiguity in the cached model tables.
- **CONFIRMED** [2]: **Batch API — flat 50% discount** on both input and output. Not available with fast mode. Not available for Managed Agents sessions.
- **CONFIRMED** [2]: **`inference_geo: "us"` costs 1.1x on everything** — "a 1.1x multiplier on all token pricing categories, including input tokens, output tokens, cache writes, and cache reads." Claude 4.6+ only; earlier models 400 on the parameter. Same 1.1x on Foundry's US Data Zone Standard deployments.
- **CONFIRMED** [2]: **Bedrock / Google Cloud regional and multi-region endpoints carry a 10% premium over global endpoints**, for Sonnet 4.5, Haiku 4.5, Opus 4.5 and all later models. **This confirms the project doc's "cross-region inference profiles add ~10% premium" claim** — though the precise framing is regional/multi-region *vs global*, not cross-region profiles per se.
- **CONFIRMED** [2]: **Tool-use system prompt overhead varies ~2.4x across models.** With `tool_choice: auto/none`: Opus 5 = 286 tokens, Opus 4.8 = 290, **Opus 4.7 = 675**, Opus 4.6 = 497, Sonnet 5 = 354, Sonnet 4.6 = 497, Haiku 4.5 = 496. (`any`/`tool` adds ~120.) Bash tool adds 325 tokens on Opus 5/4.8/4.7, 244 on Opus 4.6/Sonnet 4.6 and earlier. Computer-use toolset adds **~4,500**; browser-use toolset **~6,600**.
- **CONFIRMED** [2]: **Web search = $10 per 1,000 searches**, plus tokens. Errored searches are not billed. **Web fetch = no additional charge** beyond tokens. **Code execution = 1,550 free container-hours/month per org**, then $0.05/hour/container, minimum 5-minute execution, and **free when used with `web_search_20260209`+ or `web_fetch_20260209`+**.
- **CONFIRMED** [2]: Managed Agents add **$0.08 per session-hour** of `running` time, on top of tokens. Idle/rescheduling/terminated time is not billed. Batch discount does not apply.
- **CONFIRMED** [7]: **Claude Code agent teams use ~7x more tokens** than standard sessions when teammates run in plan mode, "because each teammate maintains its own context window and runs as a separate Claude instance." Recommendation: "Use Sonnet for teammates," keep teams small, shut teammates down when done. Teams are off by default (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).
- **CONFIRMED** [7]: Enterprise-deployment baseline: "the average cost is around **$13 per developer per active day** and **$150-250 per developer per month**, with costs remaining below $30 per active day for 90% of users." Background/idle token usage is "typically under $0.04 per session."
- **CONFIRMED** [7]: `/usage` dollar figures are computed **locally at list rates** and "don't reflect promotional pricing or contracted discounts and may differ from your actual bill." Use the Console Usage page for anything authoritative. Totals reset on `/clear` (v2.1.211+).
- **CONFIRMED** [7]: On Pro/Max/Team/Enterprise, `/usage` flags "behavior flags" — long context, cache misses — when one accounts for ≥10% of recent usage. This is the fastest built-in diagnostic for a cache problem.
- **CONFIRMED** [6]: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` removes 1M variants and treats natively-1M models as 200K. Relevant where a plan requires usage credits for 1M (Sonnet 4.6 with 1M requires credits on **every** plan including Max; Opus 1M is included on Max/Team/Enterprise, credits-gated on Pro).
- **CONFIRMED** [6]: Claude Code `default` model resolution — Max / Team Premium / Enterprise PAYG / Anthropic API / Claude Platform on AWS / Bedrock / Google Cloud → **Opus 5**. Pro / Team Standard / Enterprise subscription seats → **Sonnet 5**. Microsoft Foundry → Sonnet 4.5. **Fable 5 is never the default on any account type.**
- **CONFIRMED** [10]: **Bedrock cost trap** — "a deployment that doesn't pin a primary model is billed at the Opus rate once it updates to v2.1.207 or later." Without `ANTHROPIC_DEFAULT_OPUS_MODEL`, the `opus` alias on Bedrock resolves to Opus 5; without `ANTHROPIC_DEFAULT_SONNET_MODEL`, `sonnet` resolves to Sonnet 4.5. **Pin models in any Bedrock toolkit.**
- **CONFIRMED** [10]: Bedrock service tiers exist: `ANTHROPIC_BEDROCK_SERVICE_TIER` = `default` | `flex` | `priority`, sent as the `X-Amzn-Bedrock-Service-Tier` header. Availability varies by model and region. **AWS's tier pricing was not verified here.**

### 8. The Bedrock Mantle endpoint — real, but the Gemini description is mostly unsupported

- **CONFIRMED** [10]: **`CLAUDE_CODE_USE_MANTLE` is a real environment variable.** "Mantle is an Amazon Bedrock endpoint that serves Claude models through the native Anthropic API shape rather than the Amazon Bedrock Invoke API. It uses the same AWS credentials, IAM permissions, and `awsAuthRefresh` configuration."
- **CONFIRMED** [10]: Model IDs use an `anthropic.` prefix with **no version suffix** — e.g. `anthropic.claude-sonnet-5`, `anthropic.claude-haiku-4-5`. Bedrock inference-profile IDs like `us.anthropic.claude-sonnet-4-6` return a **400** on Mantle. Companion vars: `ANTHROPIC_BEDROCK_MANTLE_BASE_URL`, `CLAUDE_CODE_SKIP_MANTLE_AUTH`. `/status` shows `Amazon Bedrock (Mantle)`.
- **CONFIRMED** [10]: Access is **allowlisted** — "A `403` from the Mantle endpoint with valid credentials means your AWS account has not been granted access to the model you requested. Contact your AWS account team." Mantle "has its own model lineup separate from the standard Amazon Bedrock catalog."
- **CONFIRMED** [10]: You can run both endpoints simultaneously (`CLAUDE_CODE_USE_BEDROCK=1` + `CLAUDE_CODE_USE_MANTLE=1`); Mantle-format IDs route to Mantle, everything else to the Invoke API.
- **NOT CONFIRMED — and one part contradicted**: Gemini's three specific Mantle claims are **absent from the official docs**: (a) separate input/output token quotas, (b) automatic 1-hour cache TTL, (c) work-queuing instead of hard 429s. None appear on the Claude Code Bedrock page [10] or the caching page [3].
  - **(b) is actively contradicted** [3][10]: Mantle falls under "API key or third-party provider," where "the TTL stays at the cheaper five minutes by default. To opt into the one-hour TTL, set `ENABLE_PROMPT_CACHING_1H=1`." There is no automatic 1-hour TTL on Mantle.
  - **CONFIRMED** [3]: One genuine Mantle caching benefit does exist: "System context that Claude Code appends mid-conversation, such as file-change notices, is cached on Amazon Bedrock and its Mantle endpoint... the same way it is on the Claude API. **Before v2.1.211, these providers billed that appended system context as uncached input tokens on every request.**"
  - **What would confirm the rest**: AWS's own Bedrock docs on token burndown/quotas (`docs.aws.amazon.com/bedrock/latest/userguide/quotas-token-burndown.html`, linked from [10] but not fetched) and your AWS account team's Mantle onboarding materials, which [10] says contain the model list.

### 9. Mythos 5 and Project Glasswing

- **CONFIRMED** [2]: **Claude Mythos 5 is real and is a listed model** at $10 / $50 per MTok (identical to Fable 5), marked "limited availability" and linking to **`https://anthropic.com/glasswing`**. So **Project Glasswing is real and is the access program** — this confirms the Gemini claim at the level of existence.
- **NOT CONFIRMED**: the *reason* for the restriction. No fetched source states that Mythos is limited to vetted national security / critical infrastructure partners due to cybersecurity capabilities. That characterization is currently **the team member's firsthand statement only** — see Contradictions below.

---

## Trade-offs and Alternatives

**Effort as a standing preference vs. a per-task dial.** Anthropic recommends both — "Consider dynamic effort: Adjust effort based on task complexity" [1] and, two lines later, "Hold effort constant within cached conversations" [1]. The resolution is scope: vary effort **across** workloads and sessions, hold it constant **within** a cached conversation. The blog resolves it the same way [9]: "more as a general preference than a task-by-task decision." **Recommendation for the generator: instruct users to set effort at session start (via `--effort` or `/effort`) and not touch it mid-session.** The cache penalty for changing it is certain and quantifiable; the savings are not.

**Fast mode vs lower effort for latency.** These are not substitutes. Fast mode buys latency at 2x price with **zero** quality change [5]; lower effort buys latency and cost at some quality risk [5]. For a cost-sensitive toolkit the ordering is: lower effort first, fast mode only for genuinely interactive human-in-the-loop debugging, and never on Bedrock (unavailable) [2][5].

**5-minute vs 1-hour cache TTL.** Break-even is one read at 5m, two at 1h [2]. For interactive Claude Code work with continuous turns, the 5-minute TTL is refreshed free on every hit [3] and is sufficient. The 1-hour TTL earns its 2x write premium only for **bursty** patterns with gaps of 5–60 minutes — the "stepped away for coffee" case. On an API key or Bedrock, `ENABLE_PROMPT_CACHING_1H=1` is a real lever, but only if your working rhythm actually has those gaps.

**Batch API vs interactive.** A flat 50% on both directions [2] is the largest single discount available and stacks with caching. For any toolkit workflow that is genuinely asynchronous — bulk document processing, test generation across many files, classification sweeps — batch is strictly better than tuning effort. It is incompatible with fast mode and with Managed Agents.

**The "Big Model Plans, Small Model Executes" pattern — weaker cost case than the docs claim.** See Contradictions. The pattern is still recommended, but for **context hygiene** reasons, not the stated cache-economics reason.

---

## Code / Configuration Reference

Setting effort on the API — Source [1], the effort page's cURL example:

```json
{
  "model": "claude-opus-5",
  "max_tokens": 4096,
  "messages": [{ "role": "user", "content": "..." }],
  "output_config": { "effort": "medium" }
}
```

Cache control with the 1-hour TTL — Source [3]:

```json
"cache_control": { "type": "ephemeral" }               // 5-minute TTL (default)
"cache_control": { "type": "ephemeral", "ttl": "1h" }  // 1-hour TTL, 2x write
```

Reading thinking-token spend — Source [4], the usage shape returned by the API:

```json
{
  "usage": {
    "input_tokens": 25,
    "output_tokens": 348,
    "output_tokens_details": { "thinking_tokens": 312 }
  }
}
```

Claude Code cost-relevant environment variables — Source [3], [5], [6], [7], [10]. Each traced individually; this block is a **synthesis** assembled from those pages, not a single quoted example:

```bash
# Cache TTL
ENABLE_PROMPT_CACHING_1H=1        # opt into 1-hour TTL (API key / Bedrock / etc.)  [3]
FORCE_PROMPT_CACHING_5M=1         # force 5-minute TTL regardless of auth           [3]
DISABLE_PROMPT_CACHING=1          # debugging only                                  [3]

# Effort and thinking
CLAUDE_CODE_EFFORT_LEVEL=medium   # highest-precedence effort control               [6]
MAX_THINKING_TOKENS=0             # disable thinking (no effect on Fable 5)         [6]

# Fast mode
CLAUDE_CODE_DISABLE_FAST_MODE=1   # block fast mode entirely                        [5]

# Bedrock / Mantle
CLAUDE_CODE_USE_BEDROCK=1                                                        # [10]
CLAUDE_CODE_USE_MANTLE=1                                                         # [10]
ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-8'   # pin, or be billed at Opus rates [10]
ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'                  # [10]
ANTHROPIC_BEDROCK_SERVICE_TIER=default   # default | flex | priority              # [10]
```

Per-session fast-mode opt-in, for cost control in orgs — Source [5], verbatim:

```json
{
  "fastModePerSessionOptIn": true
}
```

---

## Gaps and Open Questions

1. **Per-effort-level cost deltas do not exist in published form.** The only number is "roughly 7x more tokens" for one high-effort vs low-effort prompt in a blog whose charts are disclaimed as non-benchmark [9]. **Closing this requires empirical measurement**, not more searching: run the same representative task at `low`/`medium`/`high`/`xhigh` on one model, capture `output_tokens` and `output_tokens_details.thinking_tokens` per turn plus total tool-call count, and record it. That is a half-day experiment and would be genuinely novel content for the toolkit.
2. **Anthropic Priority Tier pricing was not found.** `BEDROCK-COST-GUIDE.md` claims "~75% premium." The official pricing page [2] has **no Priority Tier section at all**. Bedrock's own tiers (`flex`/`priority`) are configurable [10] but priced by AWS. **Needs**: the AWS Bedrock pricing page and/or an Anthropic Priority Tier docs page. Until then the 75% figure must be marked unverified or deleted.
3. **AWS Bedrock's own per-model prices were not verified.** All prices here are Anthropic first-party rates [2], which the docs state also apply to Microsoft Foundry but explicitly **not** to Bedrock or Vertex ("partner-operated with separate pricing"). The Bedrock numbers in `BEDROCK-COST-GUIDE.md` happen to match first-party rates, which is plausible but unconfirmed. **Needs**: `https://aws.amazon.com/bedrock/pricing/`.
4. **Bedrock per-model cache minimums differ from first-party.** [3] notes "Bedrock (non-legacy AWS-operated) uses its own per-model minimums documented by AWS" and [10] warns prompt caching "may not be available in all Amazon Bedrock regions." A Bedrock toolkit cannot assume the 512/1024/2048/4096 table applies. **Needs**: the AWS prompt-caching supported-models page.
5. **The Mantle quota/queuing claims remain open** — see §8. Needs AWS's token-burndown docs and Mantle onboarding materials.
6. **`speed` as a cache-key component** is described inconsistently between the API caching page and the Claude Code caching page (§5). Needs empirical check via `cache_read_input_tokens` if anyone builds directly against the API with fast mode.
7. **Whether a long-context premium ever existed** (the likely origin of the refuted 2x claim) is inferred, not confirmed. Low priority.
8. **No source found for the Mythos access-restriction rationale.** Existence and the Glasswing program are confirmed [2]; the reason is not.

---

## Contradictions with Prior Knowledge

**1. `BEDROCK-COST-GUIDE.md`: "Context Length Surcharge — Gemini describes a 2x billing multiplier for tokens beyond 200K." — REFUTED [2][8].** Standard pricing across the full 1M window; "A 900k-token request is billed at the same per-token rate as a 9k-token request." Delete this section.

**2. `BEDROCK-COST-GUIDE.md`: "Cache break-even: approximately 2 reads." — PARTIALLY WRONG [2].** One read at 5-minute TTL; two reads at 1-hour TTL. Since 5-minute is the default on API keys and Bedrock, the practical break-even for most toolkit users is **one** read.

**3. `MODEL-SELECTION.md` effort table: `high` = "Extended thinking enabled" and `low` = "Minimal reasoning." — MISLEADING [1][4].** On all current models thinking is adaptive and can occur at any effort level; `low` "minimizes thinking. Skips thinking for simple tasks" [4] rather than disabling reasoning. More importantly, the table frames effort as a thinking-depth dial when the docs are explicit that it governs **all** token spend including tool-call count and preamble [1]. The table should be rewritten around "how thorough, across thinking + tool calls + prose."

**4. `MODEL-SELECTION.md`: "`max` — Maximum thinking budget."** There is no budget [4]. `max` = "no constraints on token spending," and the docs warn it "can lead to overthinking" on structured-output tasks and "adds significant cost for relatively small quality gains" on most workloads [1].

**5. The "Big Model Plans, Small Model Executes" cost rationale is weaker than both docs claim — CONTRARIAN, flagged not resolved.** Both `MODEL-SELECTION.md` and `BEDROCK-COST-GUIDE.md` justify the pattern as "avoids paying the cache re-write penalty that model switching triggers mid-session." Three problems:
  - **The re-write is paid either way.** A fresh Sonnet session must write the handoff docs into *its own* cache regardless of whether the Opus session was closed first — caches are model-scoped [3]. Closing the session avoids a *larger* re-write (full conversation vs. just the handoff docs), which is a real but different and smaller benefit than "avoiding the penalty."
  - **"Close the session — cache expires, no ongoing cost"** implies idle caches cost money. **INFERRED**: they don't — the pricing page lists only write and read operations with no storage SKU [2]. The sentence is true but for the wrong reason, and it teaches a wrong mental model.
  - **The economics can invert.** Anthropic's own guidance [9] says that on hard multi-step work the smaller model "burns iterations" so "the total cost per task can come out lower" on the *larger* model — and that some tasks are unreachable by the smaller model "even at the highest effort settings." Handing a hard plan to Sonnet to save per-token cost can cost more in total.
  - **Recommendation**: keep the pattern, re-justify it on the grounds that actually hold — a clean context boundary, a durable written artifact, avoiding mid-session invalidation, and matching capability to task — and drop the claim that it avoids a cache penalty.

**6. Team member's firsthand statement on Mythos** ("real model, restricted to vetted national security and critical infrastructure partners due to extreme cybersecurity capabilities"). **Existence and the Glasswing gating are now confirmed** [2]. The restriction rationale is **neither confirmed nor contradicted** by any fetched source. Per protocol, the firsthand statement stands as the stronger prior; the research simply has nothing to say about the "why." Do not present the rationale as sourced in `MODEL-SELECTION.md`.

**7. `MODEL-SELECTION.md` Haiku 4.5 API ID `claude-haiku-4-5-20251001`.** The current canonical first-party ID is `claude-haiku-4-5` with no date suffix; the dated form is the Bedrock inference-profile shape (`us.anthropic.claude-haiku-4-5-20251001-v1:0`) [10]. Minor, but it will fail as a first-party API model string.

---

## Sources

[1] Effort — https://platform.claude.com/docs/en/build-with-claude/effort
[2] Pricing — https://platform.claude.com/docs/en/about-claude/pricing
[3] Prompt caching (API) — https://platform.claude.com/docs/en/build-with-claude/prompt-caching ; How Claude Code uses prompt caching — https://code.claude.com/docs/en/prompt-caching
[4] Steering thinking (adaptive thinking, effort levels, cost control, pricing) — https://platform.claude.com/docs/en/build-with-claude/thinking-steering-and-cost
[5] Speed up responses with fast mode (Claude Code) — https://code.claude.com/docs/en/fast-mode
[6] Model configuration (Claude Code) — https://code.claude.com/docs/en/model-config
[7] Manage costs effectively (Claude Code) — https://code.claude.com/docs/en/costs
[8] Context windows — https://platform.claude.com/docs/en/build-with-claude/context-windows
[9] Choosing a Claude model and effort level in Claude Code (Anthropic blog) — https://claude.com/blog/claude-model-and-effort-level-in-claude-code
[10] Claude Code on Amazon Bedrock — https://code.claude.com/docs/en/amazon-bedrock
