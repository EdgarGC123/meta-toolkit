# Bedrock and Claude Model Claims — Verification Reference

**Research date**: 2026-08-21
**Confidence**: High — every in-scope claim was checked against Tier 1 sources (Anthropic platform docs, Claude Code docs, AWS Bedrock user guide). One claim (priority tier premium) is Medium because the number is documented on the AWS pricing page but not on the Anthropic tab.
**TODO reference**: "Verify Bedrock/model claims from Gemini research session" (`TODO.md`)
**Purpose**: Determine what stays, what gets corrected, and what gets removed from `.meta/BEDROCK-COST-GUIDE.md` so it can be used for real cost planning.

---

## Key Finding

Gemini got the **names** right and the **mechanics** wrong. Mantle, Mythos, and Project Glasswing are all real and documented — but every functional property Gemini attributed to Mantle is either false or a garbled description of a different Bedrock feature, and the headline cost claim (2x billing above 200K tokens) is flatly contradicted by the official pricing page. The most expensive error in the current guide is not one of the INFERRED items: it is the `bedrock:InvokeModel`-only IAM policy in the section marked **CONFIRMED**, which will not actually run Claude Code.

---

## Verification Table

| # | Claim | Verdict | Source |
|---|---|---|---|
| 1a | An "Amazon Bedrock Mantle endpoint" exists | **CONFIRMED** | [1] [2] |
| 1b | Enabled via `CLAUDE_CODE_USE_MANTLE=1` | **CONFIRMED** | [1] |
| 1c | Mantle separates input/output token quotas | **REFUTED** — that is the Bedrock *Reserved tier*, not Mantle | [2] [5] |
| 1d | Mantle extends cache TTL to 1 hour | **REFUTED** — 1h TTL is an unrelated per-request opt-in billed at 2x | [1] [6] [8] |
| 1e | Mantle work-queues instead of returning 429 | **REFUTED as described** — no queuing documented anywhere | [2] [5] |
| 2a | Claude Mythos exists as a model tier | **CONFIRMED** — `claude-mythos-5` and `claude-mythos-preview` | [3] [4] |
| 2b | Restricted to vetted partners, not self-serve | **CONFIRMED** (scope is defensive cybersecurity, not national security) | [3] [4] [7] |
| 2c | Relaxed safety classifiers vs. Fable | **CONFIRMED** — Mythos 5 ships *without* Fable 5's safety classifiers | [4] |
| 2d | Identical weights, different safety deployment | **UNVERIFIABLE** — docs say "same capabilities/specs", never "same weights" | [4] [7] |
| 2e | Mythos pricing is published | **CONFIRMED** — $10/$50 per MTok, identical to Fable 5 | [8] |
| 3 | Project Glasswing is the restricted access program for Mythos | **CONFIRMED** (with scope correction — see Findings) | [3] [7] |
| 4 | ~2x billing multiplier for input above 200K on 1M-context models | **REFUTED** | [8] [9] |
| 5a | Guide's pricing table (Haiku 4.5, Sonnet 4.6) | **CONFIRMED** for those two rows; table is incomplete and mislabeled | [8] |
| 5b | Cross-region inference adds ~10% | **CONFIRMED but mislabeled** — the premium is *regional vs. global*, and both are cross-region | [1] [2] [8] |
| 5c | Priority tier adds ~75% | **PARTIALLY CONFIRMED** — real Bedrock figure, not stated on the Anthropic tab | [10] |
| 6a | `CLAUDE_CODE_USE_BEDROCK=1` + `AWS_REGION` | **CONFIRMED** — `AWS_REGION` is now optional | [1] |
| 6b | Minimum IAM is `bedrock:InvokeModel` only | **REFUTED** — six actions required | [1] |

---

## Findings

### 1. The Mantle endpoint — real name, fabricated mechanics

- **CONFIRMED** [1]: Mantle is real and documented in Claude Code's own Bedrock page. Verbatim: *"Mantle is an Amazon Bedrock endpoint that serves Claude models through the native Anthropic API shape rather than the Amazon Bedrock Invoke API. It uses the same AWS credentials, IAM permissions, and `awsAuthRefresh` configuration described earlier on this page."*
- **CONFIRMED** [1]: `CLAUDE_CODE_USE_MANTLE=1` is the correct variable. Companion variables: `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` (override endpoint URL), `CLAUDE_CODE_SKIP_MANTLE_AUTH` (gateway/proxy setups). `/status` shows `Amazon Bedrock (Mantle)` when active.
- **CONFIRMED** [2]: The endpoint URL pattern is `https://bedrock-mantle.{region}.api.aws/anthropic/v1/messages`. Mantle model IDs carry an `anthropic.` prefix with no version suffix (`anthropic.claude-opus-5`, `anthropic.claude-haiku-4-5`). Inference-profile IDs like `us.anthropic.claude-sonnet-4-6` return a 400 on Mantle — it has its own model lineup.
- **CONFIRMED** [1]: You can run both endpoints at once (`CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1`); Mantle-format IDs route to Mantle, everything else to the Invoke API.
- **REFUTED** [2] [5]: Mantle does **not** separate input/output token quotas. Mantle's documented quota is *"2 million input tokens per minute (TPM). You can request up to 4 million input TPM without additional Anthropic approval. AWS enforces requests-per-minute (RPM) limits on the Bedrock side."* The feature Gemini described — independently allocated input and output TPM — is the Bedrock **Reserved tier**: *"You have the flexibility to allocate different input and output tokens-per-minute capacities to match the exact requirements of your workload"* (minimums: 100,000 input TPM, 10,000 output TPM, 1- or 3-month commitment) [5]. This is a paid capacity reservation requiring AWS account-team involvement, not an endpoint flag.
- **REFUTED** [1] [6] [8]: Mantle does not extend cache TTL. The 1-hour cache is an explicit opt-in — `"cache_control": {"type": "ephemeral", "ttl": "1h"}` at the API level, or `ENABLE_PROMPT_CACHING_1H=1` in Claude Code — and it is billed at 2x base input instead of 1.25x. Claude Code's Bedrock page states this in the Invoke-API section, not the Mantle section, and nothing links TTL to Mantle.
- **REFUTED as described** [2] [5]: No work-queuing. Nothing in the Mantle docs or the Bedrock service-tiers docs describes queuing in place of throttling errors. The nearest real feature is the **Flex tier** — *"For workloads that can handle longer processing times, the Flex tier offers cost-effective processing for a pricing discount"* — and even that shares quota: *"Your on-demand quota for a model is shared across the 'priority', 'default', and 'flex' service tiers."* [5] Claude Code exposes tiers via `ANTHROPIC_BEDROCK_SERVICE_TIER` (`default` | `flex` | `priority`), sent as the `X-Amzn-Bedrock-Service-Tier` header [1].

**Net**: keep Mantle in the guide, rewrite it entirely. It is an API-shape change (native Messages API, SSE streaming, allowlisted model lineup), not a quota or caching feature.

### 2. Claude Mythos — confirmed, including the safety-classifier difference

- **CONFIRMED** [4]: Verbatim from the launch page: *"Claude Mythos 5 shares Claude Fable 5's capabilities without the safety classifiers. Available through Project Glasswing. Successor to Claude Mythos Preview."* And: *"The headline change for integrations: Claude Fable 5 includes safety classifiers that can decline requests. Claude Mythos 5 does not include these classifiers."* The team member's firsthand claim that Mythos is real is fully corroborated.
- **CONFIRMED** [3] [4]: Access is invitation-only with no self-serve path. *"Claude Mythos 5 and Claude Mythos Preview are offered separately for defensive cybersecurity workflows as part of Project Glasswing. Access is invitation-only and there is no self-serve sign-up."* On Bedrock, Mythos Preview additionally *"requires a dedicated AWS account that has been allowlisted by the Bedrock Marketplace team"*, submitted by an Anthropic account executive (~24h) [2]. Mythos Preview is regional-only in `us-east-1` [2]. The AWS pricing page confirms access *"is gated and requires approval"* [10].
- **CONFIRMED** [8]: Mythos 5 pricing is published and identical to Fable 5 — $10/MTok input, $50/MTok output, $12.50 5m cache write, $20 1h cache write, $1 cache read, $5/$25 batch. Glasswing's own announcement lists post-preview pricing of *"$25/$125 per million input/output tokens"* for Mythos **Preview** [7] — treat these as two different SKUs, not a contradiction.
- **UNVERIFIABLE** [4] [7]: "Identical weights, different safety deployment." Every official phrasing is about *capabilities* and *specs* — "shares the same capabilities", "share the same specs and pricing". No Anthropic page addresses weights, and the Glasswing page is silent on weights, sharing, or hosting. Reasoning: capability parity plus classifier-only difference is consistent with shared weights, but it is equally consistent with a separately trained model. Risk if wrong: low for cost planning, but do not state it as fact in the guide.
- **SCOPE CORRECTION** [3] [7]: The TODO wording ("national security / critical infrastructure partners due to extreme cybersecurity capabilities") is close but should be tightened. Docs frame it as **defensive cybersecurity** for organizations that build or maintain **critical software infrastructure**. Anthropic states *"We do not plan to make Claude Mythos Preview generally available"* and that it must *"make progress in developing cybersecurity (and other) safeguards that detect and block the model's most dangerous outputs"* [7].
- **CONFIRMED** [3]: For `MODEL-SELECTION.md` — Fable 5 is the top *widely released* tier and *"offers the same capabilities"* for customers without Mythos access. Mythos should not appear in a general model-selection table.

### 3. Project Glasswing — real, broader than "the Mythos access program"

- **CONFIRMED** [7]: Announced 2026-04-07 as *"a new initiative that brings together Amazon Web Services, Anthropic, Apple, Broadcom, Cisco, CrowdStrike, Google, JPMorganChase, the Linux Foundation, Microsoft, NVIDIA, and Palo Alto Networks"* plus *"over 40 additional organizations that build or maintain critical software infrastructure."* Funding: up to $100M in usage credits and $4M in direct donations.
- **CONFIRMED** [3] [4]: Mythos access does run through Glasswing — every Anthropic doc that mentions Mythos links to `anthropic.com/glasswing` for access. Gemini's framing is directionally right but inverted in emphasis: Glasswing is a cross-industry defensive-security initiative whose model access happens to be Mythos, not an access program built around a model. Open-source maintainers can apply via the Claude for Open Source program [7].
- **CONFIRMED** [7]: Stated capability motivation — Mythos Preview reportedly found flaws *"in every major operating system and every major web browser"*, including a 27-year-old OpenBSD bug and a 16-year-old FFmpeg bug; CyberGym 83.1% vs. 66.6% for Opus 4.6.

### 4. Context length surcharge — fabricated

- **REFUTED** [8]: The pricing page's *Long context pricing* section, verbatim: *"Claude 4.6 and later models and Claude Mythos Preview include the full 1M token context window at standard pricing. (A 900k-token request is billed at the same per-token rate as a 9k-token request.) Prompt caching and batch processing discounts apply at standard rates across the full context window."*
- **REFUTED** [9]: Corroborated on the context-windows page: *"For every model with a 1M-token context window, 1M is the default: you don't need a beta header, and long-context requests are billed at standard pricing."*
- **Likely origin of the error**: earlier-generation 1M-context betas (Sonnet 4 / Sonnet 4.5 era) did carry a long-context premium behind a beta header. That structure no longer exists for 4.6+. Delete this section from the guide — it currently inflates large-context cost estimates by up to 2x.
- **Real cost lever that replaces it** [9]: *context rot*, not billing. *"As token count grows, accuracy and recall degrade."* The argument for caching and curated context is a quality argument plus a linear cost argument, not a multiplier argument.

### 5. Pricing — corrected table

**CONFIRMED** [8] — Anthropic first-party rates (USD per MTok). These also apply to Claude Platform on AWS and Microsoft Foundry. **Amazon Bedrock is partner-operated with separate pricing invoiced by AWS** [8], so use these as a planning proxy only and confirm the final rate on the AWS bill.

| Model | Base input | 5m cache write | 1h cache write | Cache hit/refresh | Output |
|---|---|---|---|---|---|
| Claude Fable 5 | $10 | $12.50 | $20 | $1.00 | $50 |
| Claude Mythos 5 (Glasswing only) | $10 | $12.50 | $20 | $1.00 | $50 |
| Claude Opus 5 | $5 | $6.25 | $10 | $0.50 | $25 |
| Claude Opus 4.8 | $5 | $6.25 | $10 | $0.50 | $25 |
| Claude Sonnet 5 | $2 | $2.50 | $4 | $0.20 | $10 |
| Claude Sonnet 4.6 | $3 | $3.75 | $6 | $0.30 | $15 |
| Claude Haiku 4.5 | $1 | $1.25 | $2 | $0.10 | $5 |

- **CONFIRMED** [8]: The guide's two filled-in rows (Haiku 4.5 $1/$5, Sonnet 4.6 $3/$15) are correct. Its single "Cache Write" column is the **5-minute** write; the 1h write is a separate, higher rate the guide never lists.
- **CONFIRMED** [8]: Sonnet 5's $2/$10 is now the standard price, not introductory: *"The previously scheduled increase to $3/$15 per million input/output tokens on September 1, 2026 will not occur."* Sonnet 5 is now cheaper than Sonnet 4.6 — the guide's tier table lists both as equivalent daily drivers, which is no longer cost-neutral.
- **GAP in the guide** [3] [8]: Opus 5 ($5/$25, 1M context) is missing entirely from both the cost table and the capability-tier table, and it is Claude Code's default primary model on Bedrock [1].
- **CONFIRMED** [8]: Batch API is a flat 50% discount on input and output. AWS confirms the same for Bedrock batch inference [10]. Not mentioned in the guide.
- **CONFIRMED** [8]: Tokenizer caveat that affects every cost estimate — *"Claude 4.7 and later models and Claude Mythos Preview use a newer tokenizer... This tokenizer produces approximately 30% more tokens for the same text."* So Opus 4.8/5 and Fable 5 cost more per unit of *text* than their per-token rate implies relative to Sonnet 4.6.

**Cross-region / regional premium — CONFIRMED but the guide's label is wrong** [1] [2] [8]:
- The 10% premium is **regional endpoints vs. global endpoints**, not "cross-region inference profiles" as a category. Verbatim: *"Regional endpoints carry a 10% pricing premium over global endpoints."* Global (`global.` prefix) has **no premium** and is the recommended default. Regional (`us.`, `eu.`, `jp.`, `apac.`) is for data residency.
- This matters operationally: Claude Code derives its prefix from your AWS region and defaults to `us.` in a `us-*` region [1] — i.e. **the default Claude Code Bedrock configuration pays the 10% premium**. Set `ANTHROPIC_BEDROCK_REGION_PREFIX=global` (requires v2.1.224+) to avoid it, if your account has `global.` profiles enabled.
- Scope: applies to Sonnet 4.5, Haiku 4.5, Opus 4.5 and all later models [8].

**Priority tier ~75% — PARTIALLY CONFIRMED** [10]:
- The AWS Bedrock pricing page does carry the footnotes *"Priority tier pricing is at 75% premium to Standard tier pricing"* and *"Flex tier pricing is at 50% discount to Standard tier pricing"* — but on other providers' tabs. They are absent from the Anthropic tab, so applying 75% to Claude is an assumption, not a sourced fact.
- **CONFIRMED** [5]: Priority tier behavior itself — *"delivers the fastest response times for a price premium over standard on-demand pricing... Priority tier requests are prioritized over Standard and Flex tier requests."* No reservation required; set `service_tier: "priority"`.
- The **Flex tier 50% discount** is the more useful and undocumented-in-our-guide lever for batch-like agentic work.

### 6. Bedrock setup for Claude Code

- **CONFIRMED** [1]: `CLAUDE_CODE_USE_BEDROCK=1` is correct. `AWS_REGION` is now **optional** — as of v2.1.172 Claude Code resolves region as `AWS_REGION` → `AWS_DEFAULT_REGION` → the active AWS profile's `region` → `us-east-1`. Set it only to override.
- **CONFIRMED** [1]: There is now an interactive setup path the guide doesn't mention — select **3rd-party platform → Amazon Bedrock** at login, or run `/setup-bedrock`. It detects credentials, resolves region, verifies invokable models, pins them, and writes to the `env` block of `~/.claude/settings.json`.
- **REFUTED** [1]: `bedrock:InvokeModel` alone is **not** sufficient. The documented minimum policy is:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowModelAndInferenceProfileAccess",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListInferenceProfiles",
        "bedrock:GetInferenceProfile"
      ],
      "Resource": [
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*",
        "arn:aws:bedrock:*:*:foundation-model/*"
      ]
    },
    {
      "Sid": "AllowMarketplaceSubscription",
      "Effect": "Allow",
      "Action": [
        "aws-marketplace:ViewSubscriptions",
        "aws-marketplace:Subscribe"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:CalledViaLast": "bedrock.amazonaws.com"
        }
      }
    }
  ]
}
```
Source [1]: verbatim from the "IAM configuration" section of the Claude Code Amazon Bedrock page. `bedrock:InvokeModelWithResponseStream` is required because Claude Code streams. Without `bedrock:GetInferenceProfile`, requests still succeed but each new model costs an extra round-trip. First-time setup also needs `bedrock:PutUseCaseForModelAccess` if you submit the use-case form via API.
- The guide's underlying security point — dedicated least-privilege identity, never root or `AdministratorAccess` — stays. Anthropic adds: *"Create a dedicated AWS account for Claude Code to simplify cost tracking and access control."* [1]
- **CONFIRMED** [1]: Bedrock-specific limitations the guide omits — the WebSearch tool is unavailable, `/logout` is unavailable, and Claude Code uses the Invoke API only (no Converse API support).

### Additional corrections to sections the guide currently marks CONFIRMED

- **`.claudeignore` does not exist.** **REFUTED** [11]: zero matches in the Claude Code settings reference. The documented mechanism is `permissions.deny` with `Read()` glob rules: `"deny": ["Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)"]`. For enforcement, put them in `managed-settings.json` with `allowManagedPermissionRulesOnly`. This is the second-highest-impact fix after the IAM policy — a user following the guide would believe sensitive files were protected when nothing was blocking them.
- **Cache break-even is wrong.** **REFUTED** [8]: the guide says "approximately 2 reads." Verbatim: *"caching pays off after one cache read for the 5-minute duration (1.25x write), or after two cache reads for the 1-hour duration (2x write)."* One read for the default TTL.
- **TTL refresh confirmed, with a clock detail the guide misses.** **CONFIRMED** [6]: *"The cache is refreshed for no additional cost each time the cached content is used."* But: *"The lifetime is measured from the start of the request that writes or reads the cache entry, not from the end of its response. Time spent generating a response counts against the lifetime: if a response takes 4 minutes to stream, a follow-up request that reuses the same cached prefix must start within about 1 minute of that response completing."* On long-running Opus/Fable turns this silently eats most of a 5-minute window — a genuine argument for `ENABLE_PROMPT_CACHING_1H=1` that the guide doesn't make.
- **Effort-change invalidation: CONFIRMED** [6]. *"Changing the `output_config.effort` value always invalidates message blocks... Setting effort explicitly to the model's default is equivalent to omitting it and does not invalidate."*
- **Model-switch invalidation: NOT documented.** The prompt-caching page never lists `model` as an invalidator; its invalidation table covers tools, system, and messages levels only. The behavior is near-certainly true in practice, but the guide labels it CONFIRMED with no source. Relabel as INFERRED — the "segment by model" workflow recommendation rests on it.
- **Fast-mode invalidation is irrelevant on Bedrock.** [8]: fast mode *"is available on the Claude API (first-party) only; it is not available on Claude Platform on AWS or partner-operated cloud platforms."* Remove it from a Bedrock-specific guide.
- **Minimum cacheable prefix varies sharply by model** [6]: 512 tokens (Opus 5, Fable 5, Mythos 5), 1,024 (Opus 4.8, Sonnet 5, Sonnet 4.6), 2,048 (Opus 4.7), **4,096 (Haiku 4.5, Opus 4.6)**. Below the minimum, caching silently does nothing and returns no error. Haiku's 4,096-token floor undercuts the guide's "small model reads the static markdown files once and caches them" pattern for small doc sets. Bedrock has its own per-model minimums — check the Bedrock prompt-caching docs.
- **Max 4 cache breakpoints; 20-block lookback window** [6]. Not in the guide.
- **Bedrock cache isolation is org-level**, while first-party/Claude Platform on AWS/Foundry are workspace-level [6].
- **Bedrock TPM burndown counts cache writes** [5]: *"your tokens-per-minute consumption includes both `InputTokenCount` and `CacheWriteInputTokens`."* Caching saves money but does not save quota on the write.
- **Two distinct Bedrock integrations now exist** [1] [2]: the legacy Invoke/Converse path with ARN-versioned IDs (Opus 4.6 and earlier), and Claude in Amazon Bedrock / Mantle (Opus 4.7+, Messages API). Fable 5, Opus 5, Sonnet 5, Opus 4.8, Opus 4.7 have **no ARN-versioned model IDs**. Anything the guide says about model IDs needs to name which path it means.
- **"No idle cost" — CONFIRMED in substance** [1] [2]: on-demand token billing only; the Reserved tier is the exception, billed monthly at a fixed price per 1K TPM until explicitly deleted [5].
- **"Cache lives on AWS GPU memory" / "code is no longer in active GPU memory"**: **UNVERIFIABLE**. No Anthropic or AWS doc describes cache storage substrate. Anthropic does state Bedrock runs *"with zero operator access (Anthropic personnel have no access to the inference infrastructure)"* [2] and that data handling is governed by Amazon Bedrock [2]. Replace the GPU-memory language with the sourced statements.

---

## Trade-offs and Alternatives

**Global vs. regional endpoint** — this is the single highest-leverage cost decision on Bedrock and the guide doesn't mention it. Global costs 10% less and has better availability; regional exists for data residency. Recommendation: use `global.` unless a client contract requires data residency, and set `ANTHROPIC_BEDROCK_REGION_PREFIX=global` explicitly rather than inheriting the region-derived `us.` default.

**Mantle vs. Invoke API** — Mantle gives native Messages API shape, SSE streaming, and access to the current model generation (Opus 5, Fable 5, Sonnet 5). The Invoke API gives the full standard Bedrock catalog and inference profiles. Mantle's constraint is its separate, allowlisted model lineup: a 403 means the account lacks model access, a 400 naming the model means it isn't served on Mantle at all [1]. Recommendation: run both flags together — that is what the docs recommend, and it removes the tradeoff.

**5m vs. 1h cache TTL** — break-even is 1 read at 5m, 2 reads at 1h. 5m refreshes free on every hit, so for continuous work 5m is strictly better. 1h wins when gaps exceed 5 minutes — and the response-time clock detail [6] means a long Opus/Fable turn can consume most of a 5-minute window on its own. Recommendation: 5m default; `ENABLE_PROMPT_CACHING_1H=1` for sessions with long thinking turns or interruptions.

**Flex tier** — 50% discount for tolerating longer processing, on the same shared quota. Unmentioned in the guide and a better fit than priority tier for most toolkit work (research passes, doc generation, batch analysis). The 75% priority premium is the wrong default to document.

**Reserved tier** — the only real "separate input/output quota" mechanism. Requires a 1- or 3-month commitment, 100K input / 10K output TPM minimums, and AWS account-team involvement. Out of scope for a personal AWS account; worth a one-line mention so the concept isn't confused with Mantle again.

---

## Gaps and Open Questions

1. **Actual Bedrock per-token prices for current Claude models.** The AWS pricing page renders its Anthropic table via JavaScript; WebFetch returned only two legacy Claude 3.5 rows [10]. The first-party table above is a planning proxy, not the Bedrock rate card. **Close it by**: opening https://aws.amazon.com/bedrock/pricing/ in a browser on the Anthropic tab, or running one real request and reading AWS Cost Explorer. Until then, treat the pricing table as CONFIRMED-first-party / INFERRED-for-Bedrock.
2. **Whether the 75% priority premium applies to Claude on Bedrock.** Same fix as above.
3. **Whether Fable 5 and Mythos 5 share weights.** Not addressed in any public doc. Likely only answerable via an Anthropic account team; not worth pursuing for cost planning.
4. **Bedrock-specific minimum cacheable prefix lengths.** Anthropic explicitly defers to AWS: *"On Bedrock, see the Bedrock prompt caching documentation for the per-model minimums, failure behavior, and usage-field names that apply."* [6] Not fetched. Matters if the toolkit relies on Haiku-tier caching.
5. **Whether model switching invalidates cache.** Universally assumed, nowhere documented. **Close it empirically**: run two requests with the same prefix on different models and compare `cache_read_input_tokens`.
6. **Regional vs. global availability for Fable 5 / Opus 5 in the target region.** The region table [2] lists endpoint types per region but access criteria are set per model by AWS. Verify with `aws bedrock list-inference-profiles --region <region>`.

---

## Contradictions with Prior Knowledge

- **TODO.md item 2 wording vs. docs (minor, resolve in favor of docs).** The TODO records Mythos as restricted "to vetted national security/critical infrastructure partners due to extreme cybersecurity capabilities." Official framing is **defensive cybersecurity** for organizations that **build or maintain critical software infrastructure** — the launch partners are technology and financial-services companies plus the Linux Foundation and Apache Software Foundation, not government bodies. The substance of the team member's claim (real, restricted, cyber-capability-driven, not publicly accessible) is fully confirmed; only the "national security" framing needs adjusting.
- **No contradiction on Mythos existing.** The user's firsthand confirmation is corroborated by four independent Tier 1 pages.
- **The guide's own CONFIRMED sections contain two sourced errors** (IAM minimum, `.claudeignore`). Flagging rather than silently rewriting: both were labeled as sourced from official docs, so the labeling process itself, not just the Gemini content, needs a pass.

---

## Sources

[1] Claude Code on Amazon Bedrock — https://code.claude.com/docs/en/amazon-bedrock
[2] Claude in Amazon Bedrock (Opus 4.7 and later) — https://platform.claude.com/docs/en/build-with-claude/claude-in-amazon-bedrock
[3] Models overview — https://platform.claude.com/docs/en/about-claude/models/overview
[4] Introducing Claude Fable 5 and Claude Mythos 5 — https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5
[5] Service tiers for optimizing performance and cost (AWS Bedrock User Guide) — https://docs.aws.amazon.com/bedrock/latest/userguide/service-tiers-inference.html
[6] Prompt caching — https://platform.claude.com/docs/en/build-with-claude/prompt-caching
[7] Project Glasswing — https://www.anthropic.com/glasswing
[8] Pricing — https://platform.claude.com/docs/en/about-claude/pricing
[9] Context windows — https://platform.claude.com/docs/en/build-with-claude/context-windows
[10] Amazon Bedrock pricing — https://aws.amazon.com/bedrock/pricing/ (Anthropic table did not render via WebFetch; see Gap 1)
[11] Claude Code settings reference — https://code.claude.com/docs/en/settings
[12] Claude on Amazon Bedrock (Opus 4.6 and earlier, legacy) — https://platform.claude.com/docs/en/build-with-claude/claude-on-amazon-bedrock-legacy
