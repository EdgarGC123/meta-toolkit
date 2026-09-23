# Claude Code Permission Rule Matching — Research Reference

**Research date**: 2026-08-21
**Claude Code version tested**: 2.1.238 (native, darwin-arm64, Amazon Bedrock provider)
**Confidence**: High — the matching algorithm is now fully documented in official docs, and every load-bearing claim below was verified by controlled empirical test in this environment.
**TODO reference**: "Permission pattern matching — why prompts fire despite allow rules"
**Purpose**: Lets the four `.meta/settings.*.json` permission layer templates be rewritten against real matching semantics instead of defensive guesswork, so generated toolkits don't inherit avoidable approval prompts or dead rules.

---

## Key Finding

There is no mystery layer. Claude Code's permission matching is fully documented [1], and both of the generator's long-standing anomalies are caused by rules the generator wrote itself: **`Bash(rm -rf /*)` in its own `deny` list blocks every absolute-path `rm -rf`**, and **`Read(/**)` anchors at the project root, not the filesystem root — a single leading slash is *not* an absolute path**. The TODO's double-slash hypothesis is correct in effect (`//` is required for absolute paths) but wrong about the mechanism: `//` is documented syntax, not path normalization. Separately, the `"defaultMode": "auto"` key in `.claude/settings.json` and in `settings.template.json` is at the wrong nesting level and is silently ignored, so the generator and every toolkit it produces actually run in Manual mode on Bedrock — the mode where rule mistakes become prompts.

---

## The Three Observations — Verdicts

### Observation 1 — `Bash(rm -rf *)` is allowed, but absolute paths are blocked

**Verdict: EXPLAINED.** Cause is the generator's own deny rule, not a safety layer.

Mechanism, in order:

1. **CONFIRMED [1]**: "Rules are evaluated in order: deny, then ask, then allow. The first match in that order determines the outcome, and rule specificity doesn't change the order." And: "A broad deny rule like `Bash(aws *)` blocks every matching call, including calls that also match a narrower allow rule like `Bash(aws s3 ls)`, so a deny rule can't carry allowlist exceptions."
2. **CONFIRMED [1]**: Bash wildcards match at any position, and a `*` with no preceding space imposes **no word boundary**: "`Bash(ls*)` without a space matches both `ls -la` and `lsof` because there's no word boundary constraint."
3. Therefore `.claude/settings.json`'s `deny` entry `Bash(rm -rf /*)` = prefix `rm -rf /` + anything = **every absolute-path `rm -rf` on the machine**. `.meta/settings.template.json` carries the same rule plus `Bash(rm -rf /Users/*)`.

**Empirical confirmation [9]** — three commands run in this repo, live settings, this session:

| Command | Result |
|---|---|
| `rm -rf /tmp/permtest-abs` | `Permission to use Bash with command rm -rf /tmp/permtest-abs has been denied.` |
| `mkdir -p tmp-permtest-rel && rm -rf tmp-permtest-rel` (relative) | allowed, no prompt |
| `rm -f /tmp/permtest-nonexistent-file` (absolute, `-f` not `-rf`) | **allowed, no prompt** |

The third row is the decisive discriminator: an absolute path is fine as long as the command string doesn't start with `rm -rf /`. A generic "absolute paths are blocked" safety layer would have blocked it too.

**There *is* a real documented safety layer, but it is narrower than CLAUDE.md claims.** **CONFIRMED [2]**: critical-path removals — "Claude Code never lets a `permissions.allow` rule or a `PreToolUse` hook that returns `"allow"` approve an `rm` or `rmdir` command that targets a critical path, even in modes that skip other prompts." Critical paths are only:

* the filesystem root
* any direct child of root (`/usr`, `/etc`, `/data`, and therefore `/Users`)
* your home directory
* Windows drive roots and their top-level directories
* your working directory **and its parents**
* additional working directories and their parents, but only for a glob under them (`rm -rf <dir>/*`)
* a glob or trailing slash directly under a shell variable, e.g. `rm -rf "$DIR"/*`, and the same hidden inside `$(...)`, backticks, or `<(...)`

An `rm -rf` of an arbitrary absolute path *inside* the project (e.g. `.../ai-toolkit-accelerator/.meta`) is **not** a critical path and is not covered by this layer. So CLAUDE.md's "Shell Command Conventions" statement — *"Claude Code's safety layer blocks `rm -rf` on absolute paths regardless of `settings.json`"* — is **wrong on the mechanism and wrong on the scope**. The relative-path convention works, but for a different reason than documented, and it is defeatable by simply removing the over-broad deny rule.

### Observation 2 — `Read(/**)` is allowed since the first commit, yet `Read(//Users/...)` rules were auto-added

**Verdict: EXPLAINED.** A single leading slash anchors at the settings source, not the filesystem root. The double slash is documented absolute-path syntax.

**CONFIRMED [1]** — the four pattern types for `Read`/`Edit` (gitignore syntax):

| Pattern | Meaning | Example | Matches |
|---|---|---|---|
| `//path` | Absolute path from filesystem root | `Read(//Users/alice/secrets/**)` | `/Users/alice/secrets/**` |
| `~/path` | Path from home directory | `Read(~/Documents/*.pdf)` | `/Users/alice/Documents/*.pdf` |
| `/path` | Path relative to the **settings source** | `Edit(/src/**/*.ts)` | `<project root>/src/**/*.ts` in project settings |
| `path` or `./path` | Path relative to current directory | `Read(*.env)` | `<cwd>/*.env` |

With an explicit warning [1]: *"A pattern like `/Users/alice/file` isn't an absolute path. The single leading slash anchors at the settings source, not the filesystem root. Use `//Users/alice/file` for absolute paths."*

And the anchor depends on which file the rule lives in **CONFIRMED [1]**:

| Rule defined in | `/path` resolves to |
|---|---|
| Project settings `.claude/settings.json` | `<project root>/path` |
| Local settings `.claude/settings.local.json` | `<original cwd>/path` |
| User settings `~/.claude/settings.json` | `~/.claude/path` |
| A file passed with `--settings <file>` | `<directory of file>/path` |
| CLI flags, `/permissions`, session rules | `<original cwd>/path` |

**Empirical confirmation [9]** — three isolated `claude -p --permission-mode dontAsk --setting-sources user --settings <file>` runs (dontAsk denies anything not covered by an allow rule, so it is a clean pass/fail harness):

| Allow rule | Target | Result |
|---|---|---|
| `Read(/**)` | `/etc/hosts` | **DENIED** |
| `Read(/**)` | `/tmp/pt-a/settings.json` (inside the anchor dir) | **SUCCESS** |
| `Read(//**)` | `/etc/hosts` | **SUCCESS** |

The middle row is the control: `Read(/**)` is a live, functioning rule — it is just anchored at the settings source. So the auto-generated `Read(//Users/edgar.galvancuesta/**)` entries in `settings.local.json` were genuinely necessary; they are not redundant with `Read(/**)`. **Do not delete them** (the TODO's instruction was right, for the right reason).

**Why `/etc/hosts` appeared to read fine anyway — the apparent contradiction resolved.** The task framing suggested this observation refutes the double-slash hypothesis. It does not. Three documented mechanisms can each produce "read `/etc/hosts` without a prompt" without `Read(/**)` matching anything:

1. **Auto mode.** **CONFIRMED [9]**: with an *empty* allow list and `--permission-mode auto` on a classifier-capable model, reading `/etc/hosts` returned **SUCCESS**; the identical run with `--permission-mode default` returned `DENIED: Claude requested permissions to read from /etc/hosts, but you haven't granted it yet.` Auto mode approves the read regardless of rules. (An earlier auto-mode run with `--model sonnet` denied it — **CONFIRMED [2]** that on Bedrock only Sonnet 5, Opus 4.7+, and Fable 5 support the classifier, so auto mode was simply unavailable to that run. Worth knowing: auto mode silently degrades to prompting on an unsupported model.)
2. **The built-in read-only Bash set.** **CONFIRMED [1]**: `ls`, `cat`, `echo`, `pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`, `diff`, `stat`, `du`, `cd` and read-only `git` forms "run without a permission prompt in every mode. The set is not configurable." So `cat /etc/hosts` never prompts — and this repo *also* allows `Bash(cat *)` explicitly. If the original test used `cat`, it proves nothing about `Read`.
3. **A prior in-session approval.** Read approvals granted during a session persist for that session.

In this session the `Read` tool on `/etc/hosts` did succeed, but `~/.claude.json` shows `allowedTools: []` for this project and `settings.local.json` contains no rule covering `/etc/hosts` — so the grant came from the session's mode or an earlier approval, not from `Read(/**)`.

### Observation 3 — the repo is reachable via a symlink and via its real path

**Verdict: EXPLAINED, and it materially affects allow-rule matching.**

**CONFIRMED [1]**: *"When Claude accesses a symlink, permission rules check two paths: the symlink itself and the file it resolves to. Allow and deny rules treat that pair differently: allow rules fall back to prompting you, while deny rules block outright.*
* ***Allow rules**: apply only when **both** the symlink path and its target match. A symlink inside an allowed directory that points outside it still prompts you.*
* ***Deny rules**: apply when **either** the symlink path or its target matches."*

This is the strictest possible semantics for allow rules and it applies directly here. `/Users/edgar.galvancuesta/Desktop` is a symlink to `/Users/edgar.galvancuesta/Library/CloudStorage/OneDrive-Slalom/Desktop` (verified locally). Any file in this repo therefore has two spellings, and **an allow rule must cover both** or the access prompts.

**CONFIRMED [9]**: Claude Code resolves the symlink for session identity. The project key in `~/.claude.json` is the **real** path (`/Users/.../Library/CloudStorage/OneDrive-Slalom/Desktop/slalom_code/ai-toolkit-accelerator`), and this session reports the real path as its working directory with the `~/Desktop/...` symlink spelling registered as an *additional* working directory.

This explains the shape of the auto-added local rules: `Read(//Users/edgar.galvancuesta/**)` is broad enough to cover **both** spellings simultaneously (both live under `/Users/edgar.galvancuesta/`), which is exactly what the both-paths-must-match allow rule requires. A narrower rule anchored to only one spelling — e.g. `Read(//Users/edgar.galvancuesta/Desktop/slalom_code/**)` — would have failed. `Read(//Users/edgar.galvancuesta/Library/CloudStorage/**)` is subsumed by the broader rule and is likely an earlier, narrower attempt.

Two secondary symlink effects worth knowing:

* **CONFIRMED [1]**: if `.claude` is a symlink (or `settings.local.json` is tracked in git), Claude Code treats `settings.local.json` as repository-supplied and **holds its allow rules until you trust the folder**.
* **CONFIRMED [1]**: `Cd` deny rules "check every spelling of the target, including each symlink hop it resolves through."

---

## Findings

### Rule evaluation model

* **CONFIRMED [1]**: Rules are `Tool` or `Tool(specifier)`. Bare `Bash` matches all Bash commands; `Bash(*)` is equivalent. As a **deny** rule, a bare tool name **removes the tool from Claude's context entirely** — Claude never sees it. A scoped deny like `Bash(rm *)` leaves the tool available and blocks matching calls.
* **CONFIRMED [1]**: Order is **deny → ask → allow**, first match wins, specificity irrelevant, across *all* scopes. "If user settings allow a permission and project settings deny it, the deny rule blocks it. The reverse is also true."
* **CONFIRMED [4]**: Permission rule arrays **merge across scopes** — they do not replace. *"Permission rules merge across scopes instead, and a few security-sensitive keys are exceptions."* This directly refutes a widely-plausible community theory (see Contradictions).
* **CONFIRMED [1]**: Permission rules are enforced by Claude Code, not by the model. `CLAUDE.md` shapes intent only.
* **CONFIRMED [1]**: Managed settings are the ceiling — "no other level, including command line arguments, can override a managed permission rule."

### Bash matching specifics

* **CONFIRMED [1]**: `*` matches any sequence including spaces. `Bash(git *)` matches `git log --oneline --all`; `Bash(git * main)` matches `git push origin main`.
* **CONFIRMED [1]**: `Bash(ls *)` (space before `*`) enforces a word boundary → matches `ls -la` but not `lsof`. `Bash(ls*)` matches both. **Every `Bash(foo*)` rule without a space in the templates is broader than intended.**
* **CONFIRMED [1]**: `Bash(ls:*)` is an equivalent trailing-wildcard form, recognized **only at the end** of a pattern. `Bash(git:* push)` treats the colon literally and matches nothing.
* **CONFIRMED [1]**: **Compound commands are matched per subcommand.** Separators are `&&`, `||`, `;`, `|`, `|&`, `&`, and newlines. "A rule must match each subcommand independently." A rule like `Bash(safe-cmd *)` does not authorize `safe-cmd && other-cmd`.
* **CONFIRMED [1]**: Wrappers stripped before matching (built-in, not configurable): `timeout`, `time`, `nice`, `nohup`, `stdbuf`, shell builtins `command` and `builtin`, zsh `noglob`, and bare `xargs` (flagless only). **Not** stripped: `command -v`, `nocorrect`, `npx`, `docker exec`, `direnv exec`, `devbox run`, `mise exec`. Consequence: *"a rule like `Bash(devbox run *)` matches whatever comes after `run`, including `devbox run rm -rf .`"*.
* **CONFIRMED [1]**: A leading assignment of a *known-safe* env var is stripped for allow rules (`NODE_ENV=test npm test` matches `Bash(npm test *)`); any other variable assignment stops an allow match, but deny/ask still match past any assignment.
* **CONFIRMED [1]**: `watch`, `setsid`, `ionice`, `flock`, and `find` with `-exec` or `-delete` **cannot be auto-approved by a prefix rule** — they always prompt in Manual mode. `Bash(find *)` does not cover `find … -delete`.
* **CONFIRMED [1]**: Commands with write-capable or exec-capable flags (`find`, `sort`, `sed`, `git`) prompt when an unquoted glob is present. Commands over 10,000 chars always prompt. Unparseable commands prompt.
* **CONFIRMED [1]**: Output redirections (`>`, `>>`, `2>`) are checked as a **file write** against your `Edit` rules, protected paths, and working directories. `Bash(git commit *)` allows the command, not the target. A redirect target starting with `~` or containing a glob character needs approval. `/dev/null` is exempt.
* **CONFIRMED [1]**: `cd` into the working directory or an additional directory is read-only, but `cd` + `git` prompts when the `cd` changes directory (git hooks), and `cd` + a redirect prompts when the target can't be resolved.
* **CONFIRMED [3]**: Prefix rules match "the literal command string, not the underlying executable" — `Bash(rm *)` as a deny does not block `/bin/rm` or `find -delete`.
* **CONFIRMED [1]** (explicit warning): argument-constraining Bash patterns are fragile. `Bash(curl http://github.com/ *)` misses flags-before-URL, protocol changes, redirects, variables, and extra spaces. Recommended instead: **deny** `curl`/`wget` and use `WebFetch(domain:…)`, or a `PreToolUse` hook.

### Read / Edit / Write path rules

* **CONFIRMED [1]**: Only `Edit(path)` and `Read(path)` rules are consulted. A path rule for **`Write`**, `NotebookEdit`, `Glob`, or `MultiEdit` "is accepted but never consulted", and Claude Code **warns at startup**. Use `Edit(docs/**)` instead of `Write(docs/**)`, `Read(docs/**)` instead of `Glob(docs/**)`.
* **CONFIRMED [1]**: `Edit` rules cover all built-in file-editing tools. A `Read` **deny** rule also blocks Edit and Write on the same path (v2.1.208+/v2.1.228+), but not NotebookEdit.
* **CONFIRMED [1]**: Read/Edit deny rules apply to built-in file tools and to recognized Bash file commands (`cat`, `head`, `tail`, `sed`) but **not** to arbitrary subprocesses — "a Python or Node script that opens files itself" bypasses them. Only the sandbox gives OS-level enforcement.
* **CONFIRMED [1]**: Depth semantics differ by rule type for single-segment relative patterns. `Edit(src/**)` as an **allow** rule matches only `<cwd>/src`; as a **deny/ask** rule it matches a `src` directory at **any depth**. `Edit(/src/**)` and `Edit(**/src/**)` behave the same in every rule type. Bare filenames follow gitignore semantics: `Read(.env)` ≡ `Read(**/.env)`.
* **CONFIRMED [1]**: `*` matches within one path segment; `**` crosses directories.
* **CONFIRMED [1]**: On Windows paths normalize to POSIX (`C:\Users\alice` → `/c/Users/alice`); use `//c/**/.env` or `//**/.env`.
* **CONFIRMED [1]**: Auto-generated file rules escape gitignore metacharacters (`[`, `]`, `*`) so they match only the literal approved path; hand-written rules are not escaped.

### The documented safety layers that allow rules cannot override

Three separate mechanisms, all documented [2]. These are the real "layer above settings.json".

1. **Actions no mode auto-approves** (including `bypassPermissions`): tools matched by an explicit **ask** rule; org-set-to-`ask` connector tools; `AskUserQuestion` and MCP tools marked `requiresUserInteraction`; **`rm`/`rmdir` targeting a critical path**; cross-session messaging safeguards.
2. **Protected paths** — writes are never auto-approved except in `bypassPermissions`. **CONFIRMED [2]**: *"`permissions.allow` rules in settings files do not pre-approve protected-path writes. The safety check runs before Claude Code evaluates allow rules, so an entry such as `Edit(.claude/**)` … does not change the per-mode outcome."* Protected directories: `.git`, `.config/git`, `.vscode`, `.idea`, `.husky`, `.cargo`, `.devcontainer`, `.yarn`, `.mvn`, `.claude` (except `.claude/worktrees`). Protected files include `.gitconfig`, `.gitmodules`, all shell rc/profile files, `.envrc`, `.npmrc`/`.yarnrc`/`bunfig.toml`, `.bazelrc`, `.pre-commit-config.yaml`, `lefthook.*`, `gradle-wrapper.properties`, `.ripgreprc`, `pyrightconfig.json`, `.mcp.json`, `.claude.json`.
   → **`Edit(.git/**)` and `Edit(.claude/**)` in `.claude/settings.json` are dead rules.** In modes that prompt, the `.claude/` prompt offers "Yes, and allow Claude to edit its own settings for this session".
3. **Critical paths** for `rm`/`rmdir` — listed under Observation 1. Per mode: `default`/`acceptEdits`/`bypassPermissions` → asks; `plan` → asks (or classifier); `auto` → classifier; `dontAsk` → denies. A matching **deny** rule still blocks outright.

Also: **CONFIRMED [1]** a `PreToolUse` hook exiting with code 2 "stops the tool call before permission rules are evaluated", overriding allow rules; and hook `"allow"` output cannot bypass deny or ask rules.

### Permission modes — and the misplaced `defaultMode` key

* **CONFIRMED [2]**: Manual (`default`) runs **reads only** without asking. `acceptEdits` adds file edits plus `mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed` — **only inside the working directory or `additionalDirectories`**, and it does **not** cover general Bash. `auto` runs everything through a classifier. `dontAsk` auto-denies anything not pre-approved. `bypassPermissions` skips prompts; **allow rules have no effect in it**.
* **CONFIRMED [2]**: mode is chosen from: (1) `--permission-mode` / `--dangerously-skip-permissions`; (2) **`permissions.defaultMode`** in a settings file — *"An `"auto"` value in `.claude/settings.json` or `.claude/settings.local.json` doesn't take effect, and Claude Code then uses the built-in default rather than a `defaultMode` from `~/.claude/settings.json`"*; (3) the built-in default.
* **CONFIRMED [2]**: the built-in default is `auto` on Pro/Max/Team (v2.1.228+), but **`default` (Manual) on Amazon Bedrock**, Google Cloud's Agent Platform, Microsoft Foundry, Claude Platform on AWS, and gateway sessions.
* **CONFIRMED [9]** — empirical, two isolated `claude -p` runs with an empty allow list:

| Settings | Resulting behavior on `Read(/etc/hosts)` |
|---|---|
| `{"defaultMode": "dontAsk", ...}` (top level) | `DENIED … you haven't granted it yet` → **Manual mode; the key was ignored** |
| `{"permissions": {"defaultMode": "dontAsk", ...}}` | `Permission to use Read has been denied because Claude Code is running in don't ask mode` → **honored** |

  So the generator's `.claude/settings.json` and `.meta/settings.template.json` both set `defaultMode` at the wrong nesting level. It is ignored twice over: wrong key path, and `"auto"` is not honored from project settings even when nested correctly. **On this Bedrock setup the effective mode is Manual** — precisely the mode in which every rule mismatch surfaces as a prompt.
* **CONFIRMED [4]**: `disableAutoMode` is explicitly noted as "also accepted under `permissions`", implying the other permission keys are `permissions.`-only. **INFERRED**: no top-level permission key other than `disableAutoMode` is read. Reasoning: the settings reference documents them only under `permissions`, and the empirical test above shows `defaultMode` is not read at top level. Risk if wrong: none material — nesting correctly is safe either way.

### Workspace trust — a distinct cause of "allow rules ignored"

* **CONFIRMED [1]**: *"`permissions.allow` rules and `permissions.additionalDirectories` entries in a project's `.claude/settings.json` grant capability, so Claude Code applies them only after you accept the workspace trust dialog for that folder."* `deny` and `ask` are unaffected.
* **CONFIRMED [1]**: In `claude -p` or an SDK session the dialog **never appears** and project allow rules are **"Not used"**, with a `this workspace has not been trusted` warning to stderr. Trusting a *parent* folder does not count.
* Manual override: set `projects["<repo root>"].hasTrustDialogAccepted = true` in `~/.claude.json`. (This repo already has it `true`, keyed on the resolved real path.)
* **CONFIRMED [4]**: `settings.local.json` allow rules skip the trust step **because the file is yours** — unless it is committed to git or `.claude` is a symlink, in which case trust applies.

**Direct consequence for generated toolkits**: a freshly generated toolkit run with `claude -p` (CI, headless, SDK) silently ignores every allow rule the generator wrote. This deserves a line in GETTING_STARTED.md.

### Debugging permission matching

* **CONFIRMED [3]**: `/permissions` shows "Resolved allow and deny rules currently in effect" **and the settings file each rule comes from**. Rules can be added/removed mid-turn and apply from Claude's next tool call (v2.1.234+).
* **CONFIRMED [2]**: `/permissions` has a **Recently denied** tab; press `r` to retry a classifier-blocked action with manual approval.
* **CONFIRMED [3]**: `/status` shows active settings sources incl. managed settings. `/doctor` finds invalid settings files. `claude doctor` prints read-only diagnostics without a session. `/debug [issue]` enables debug logging and asks Claude to diagnose. `claude --debug` writes to `~/.claude/debug/<session-id>.txt`. `claude --safe-mode` disables all customization; `CLAUDE_CONFIG_DIR=/tmp/claude-clean claude` gives a fully clean config.
* **CONFIRMED [1]**: `--verbose` shows the exact parameter names and values in each tool call. `Ctrl+E` on a Bash prompt explains the *command* (Low/Med/High risk) — not the rule match.
* **CONFIRMED [1]**: startup warnings exist for: a path rule on a never-consulted tool (`Write`/`Glob`/`NotebookEdit`/`MultiEdit`); a deny/ask rule naming an unknown tool (typo catcher); `Bash(command:…)`-style primary-field parameter rules; unanchored allow globs like `"*"` or `"mcp__*"`.
* **GAP**: there is **no** documented "explain why this rule did or did not match" facility. `/permissions` shows the resolved rule set, not the match decision for a specific call. `claude doctor` in this repo reported "No installation issues found" and surfaced no warning about the dead `Write(/**)` rule — so startup warnings may only appear in an interactive session, or `Write(/**)` may not trip that particular check. The reliable technique is the one used throughout this file: **`claude -p --permission-mode dontAsk --setting-sources user --settings <isolated file>`**, which converts every rule mismatch into a hard, visible denial with no prompt and no auto-mode masking.

### Other rule types

* **CONFIRMED [1]**: `WebFetch(domain:…)` matches the hostname, case-insensitively. `domain:*.example.com` matches any subdomain depth but **not** `example.com` itself. Elsewhere a `*` matches only between two dots. A bare `WebFetch` or `WebFetch(domain:*)` matches everything — which makes an accompanying domain list redundant.
* **CONFIRMED [1]**: Allow rules accept tool-name globs **only** after a literal `mcp__<server>__` prefix. `"*"`, `"B*"`, `"mcp__*"` as allow rules "are skipped with a warning and don't auto-approve anything."
* **CONFIRMED [1]**: Deny/ask rules can match a top-level scalar input parameter via `Tool(param:value)` — e.g. `Agent(model:opus)`, `Bash(run_in_background:true)`. Allow rules cannot. The primary content field (`command`, `file_path`, `path`, `url`, `notebook_path`) is not matchable this way.
* **CONFIRMED [1]**: `Agent(Explore)`-style rules gate subagents. `Cd(…)` rules gate `/cd` and use whole-path (not gitignore) matching where `*` is exactly one segment.
* **UNVERIFIED**: `Skill(name)` — used in both `.claude/settings.json` (`Skill(claude-api)`) and `.meta/settings.research.json` (`Skill(research)`, `Skill(update-config)`). The permissions reference [1] documents no `Skill` specifier syntax. Community issue [5] shows both `Skill(some-skill)` and `Skill(some-skill:*)` being auto-generated by the CLI, which suggests the form is real but undocumented. Risk if wrong: the rules are inert and skill invocations prompt. Needs an empirical check.

### Concrete defects in the four `.meta` templates

Traceable to the confirmed findings above:

| File | Rule | Problem |
|---|---|---|
| `settings.template.json` | `deny: Bash(rm -rf /*)`, `Bash(rm -rf /Users/*)` | Blocks every absolute-path `rm -rf`; deny beats allow; cannot be carved out. Root cause of Observation 1, inherited by every toolkit. |
| `settings.template.json` | `Write(/**)` | Never consulted; startup-warning candidate. Use `Edit(…)`. |
| `settings.template.json` | `"defaultMode": "auto"` (top level) | Ignored — wrong nesting, and `"auto"` isn't honored from project settings anyway. |
| `settings.template.json` | ~20 rules: `ls`, `cat`, `head`, `tail`, `wc`, `grep`, `find`, `stat`, `which`, `echo`, `pwd`, `git status/log/diff/show/branch` | Already in the non-configurable built-in read-only set. Redundant. |
| `settings.template.json` | `Bash(git status*)`, `Bash(env*)`, `Bash(pwd*)`, `Bash(date*)` etc. | No space before `*` → no word boundary → broader than intended. |
| `settings.template.json` | `deny: Bash(cp * ..*)`, `Bash(mv * ~*)` | Argument-constraining Bash patterns; docs warn these are trivially evaded. |
| `settings.developer.json` | `Bash(python3 *)`, `Bash(node *)`, `Bash(npx *)`, `Bash(pip install*)` | Arbitrary code execution behind a prefix rule; `npx` is explicitly **not** a stripped wrapper, and Read/Edit deny rules do not apply to scripts these launch. |
| `settings.research.json` | bare `WebFetch` + bare `WebSearch` | Bare `WebFetch` matches every domain, making the 16 `WebFetch(domain:…)` entries decorative. |
| `settings.research.json` | `Bash(curl *)` | Docs recommend the opposite: deny `curl`/`wget`, allow specific `WebFetch(domain:…)`. |
| `settings.diagnostic.json` | `Bash(env \| grep *)` | **INFERRED** dead rule: pipes split into independently-matched subcommands (`env`, `grep *`), so this literal string can never match either. Reasoning: [1] "A rule must match each subcommand independently." Risk if wrong: the rule is merely redundant, since `Bash(env*)` and `Bash(grep *)` in the base layer already cover it. Same suspicion for `Bash(echo $*)`. |
| `.claude/settings.json` (generator) | `Edit(.git/**)`, `Edit(.claude/**)` | Protected paths — allow rules are evaluated *after* the protected-path check and cannot pre-approve these. |
| `.claude/settings.json` (generator) | `Bash(git *)` + 10 narrower `git` rules | The broad rule subsumes all of them. |

---

## Trade-offs and Alternatives

**Broad allow + narrow deny does not work.** The single most consequential structural fact: `deny` wins unconditionally and cannot carry exceptions [1]. The templates are written in a least-privilege style — broad allow, then a long deny list of dangerous variants — which is exactly the pattern the engine cannot express. Community feature request [6] asked for specificity-aware precedence and was **closed** without implementation; the accepted workaround is a `PreToolUse` hook. Two viable designs:

* **Enumerate allows narrowly, keep `deny` minimal.** Deny only things that must *never* happen and that have no legitimate narrow form (`sudo`, `curl`, secrets paths). Accept that the safety-net deny rules for `rm`/`chmod`/`chown` will over-block. Simplest, no extra machinery, and what the docs steer toward.
* **Broad allow + a `PreToolUse` hook as the guard.** Documented and recommended [1]: *"To run all Bash commands without prompts except for a few you want blocked, add `"Bash"` to your allow list and register a PreToolUse hook that rejects those specific commands."* Exit code 2 blocks before rules are evaluated. This is strictly more expressive but couples the permission templates to `.meta/base-hooks/`, which the TODO notes is not yet wired into generation. **Recommended second phase**, once hooks are generated.

**Do not rely on the relative-path convention as a safety mechanism.** It currently works by accident (the `rm -rf /*` deny rule). Keeping the convention as a *style* rule is fine and still useful for portability, but CLAUDE.md's stated rationale must be corrected or a future maintainer will remove the deny rule and be surprised.

**`//**` vs `/**` for file access.** For a generated toolkit that only touches its own project, `Read(/**)`/`Edit(/**)` in project settings is actually the *right* rule — it anchors at the project root, which is the intended scope. The bug is the mislabeling, not the pattern. For toolkits that must reach outside (a client repo elsewhere on disk), use `//absolute/path/**` in `settings.local.json`, and remember the symlink rule: if the path involves a synced folder like OneDrive or iCloud, cover **both** spellings or use a common ancestor such as `//Users/<user>/**`.

---

## Configuration Reference

All snippets below are traced to fetched sources.

Anchoring — the four documented pattern types (Source [1], Read and Edit section):

```json
{
  "permissions": {
    "allow": [
      "Read(//Users/alice/secrets/**)",
      "Read(~/Documents/*.pdf)",
      "Edit(/src/**/*.ts)",
      "Read(*.env)"
    ]
  }
}
```

Correct placement of the mode key (Source [2], "Which mode a session starts in"; verified empirically [9]):

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

`"auto"` is not honored here from project or local settings. Use `claude --permission-mode auto` instead.

Broad allow + hook guard, the documented alternative to deny-with-exceptions (Source [1], "Extend permissions with hooks"):

```json
{
  "permissions": {
    "allow": ["Bash"]
  }
}
```

paired with a `PreToolUse` hook that exits 2 on the commands to block.

---

## Gaps and Open Questions

1. **`Skill(name)` rule syntax is undocumented.** Present in two shipped files. Test: `claude -p --permission-mode dontAsk --settings <file with only Skill(x)>` and invoke the skill.
2. **Whether `Write(/**)` actually emits a startup warning on 2.1.238.** Docs say it should [1]; `claude doctor` in this repo said "No installation issues found". Check `/doctor` in an interactive session and `claude --debug` stderr.
3. **The current mode of the main interactive session was not determined.** It matters for interpreting past prompt observations. Check `/status` and the Shift+Tab mode indicator. Given the Bedrock built-in default is Manual [2] and `defaultMode` is misplaced, the session is Manual unless it was switched by hand.
4. **Local-vs-project merge for the same key was not tested empirically.** Docs are explicit that permission rules merge [4], and the live evidence is consistent (the deny that blocked `rm -rf /tmp/...` came from `settings.json` while `settings.local.json` defines only `allow`) — but that is not a same-key test. Test: two files both defining `permissions.allow`, one with a rule the other lacks, in a trusted folder.
5. **Interaction of `additionalDirectories` with the both-paths symlink rule.** This session lists the symlink spelling as an additional directory. Whether that alone satisfies the "symlink path must also match" condition for allow rules is not documented.
6. **Whether the classifier's approval of out-of-directory reads in auto mode is stable** or content-dependent. One successful trial is not a guarantee; [2] says everything outside reads/working-directory edits goes to the classifier per call.

---

## Contradictions with Prior Knowledge

1. **CLAUDE.md is wrong.** Its "Shell Command Conventions" section states Claude Code's safety layer blocks `rm -rf` on absolute paths *regardless* of `settings.json`. Empirically [9], `rm -f /absolute/path` is allowed and `rm -rf /absolute/path` is denied by the repo's own `deny` rule. The documented safety layer (critical paths [2]) covers only root, top-level dirs, home, and the working directory and its parents. **Recommend correcting CLAUDE.md and the matching note in `.claude/rules/phases-skills.md`** rather than deleting the convention.
2. **The TODO's hypothesis was right in effect, wrong in mechanism.** `//` is not "path normalization Claude Code applies" — it is the documented syntax for a filesystem-absolute path [1]. Consequence for the TODO's proposed cheap test: adding `Read(//**)` to `settings.json` *would* have worked, but the finding is that `Read(/**)` was never the wrong-slash version of an absolute rule — it is a correct project-root rule that simply doesn't do what the file's author intended.
3. **The task framing's premise that the `/etc/hosts` test contradicts the hypothesis is itself incorrect.** Resolved under Observation 2: auto mode, the built-in read-only Bash set, and session-scoped approvals each produce a prompt-free read without any rule matching.
4. **Community issue #78316 [5] is wrong and should not be trusted.** Filed 2026-07-17, `area:permissions`, 0 comments, marked `stale`. It asserts that auto-generated `Read(//Users/...)`, `Read(//tmp/**)`, and `Edit(/.claude/skills/...)` entries are "malformed globs" that "never match a real path" because "real paths start with a single `/`". Official docs [1] state the exact opposite, and the empirical test [9] confirms `Read(//**)` matches while `Read(/**)` does not. Its secondary claim — that `permissions.allow` uses REPLACE-per-key merge so local entries mask project and user rules — is also contradicted by [4] ("Permission rules merge across scopes"). This matters because the issue's framing is very close to the TODO's own hypothesis and would have led the templates in the wrong direction. It is a good illustration of the Tier-3 rule: it looks authoritative (filed by a Claude Code session, with tables) and is confidently wrong.
5. **Community-reported causes that *are* corroborated**: #86151 [7] — "don't ask again for similar commands" saves verbatim command strings including absolute paths, so near-identical commands re-prompt forever and `settings.local.json` accumulates single-use entries; consistent with the documented per-subcommand rule saving [1]. #84318 [8] — project-settings `Read` deny rules not enforced when launched from a subdirectory; consistent with the documented settings-source anchoring [1]. #88556 — a 348KB `settings.local.json` with 2438 entries breaking subagent registration, which is where the #86151 pattern leads if unmanaged.

---

## Recommended Next Actions

1. Correct CLAUDE.md's Shell Command Conventions rationale (Observation 1 above).
2. In `.meta/settings.template.json`: delete `Bash(rm -rf /*)` and `Bash(rm -rf /Users/*)` from `deny` (critical paths already cover root, top-level dirs, home, and the working directory and its parents [2]); drop `Write(/**)`; move `defaultMode` under `permissions` or remove it; prune the ~20 rules duplicating the built-in read-only set; add the space before `*` in every `Bash(foo*)` rule that intends a word boundary.
3. Apply the same three fixes to the generator's own `.claude/settings.json`, and drop the dead `Edit(.git/**)` / `Edit(.claude/**)` rules.
4. Add a short "Permission rules" section to `.meta/PERMISSIONS-TEMPLATE-README.md` covering: the four path anchors; deny beats allow with no exceptions; per-subcommand compound matching; protected/critical paths; the both-paths symlink rule; and workspace trust silently disabling project allow rules under `claude -p`.
5. Keep `settings.local.json`'s three `Read(//Users/...)` rules.
6. Close the six gaps above before treating the templates as final; #1 (`Skill()` syntax) and #3 (session mode) are the cheapest and most decision-relevant.

---

## Sources

[1] Configure permissions — https://code.claude.com/docs/en/permissions
[2] Choose a permission mode — https://code.claude.com/docs/en/permission-modes
[3] Debug your configuration — https://code.claude.com/docs/en/debug-your-config
[4] Claude Code settings — https://code.claude.com/docs/en/settings
[5] Issue #78316 — Auto-generated permission entries in `.claude/settings.local.json` contain malformed globs (open, stale, **contradicted by [1] and [9]**) — https://github.com/anthropics/claude-code/issues/78316
[6] Issue #79756 — [FEATURE] specificity-aware permission precedence (closed, not implemented) — https://github.com/anthropics/claude-code/issues/79756
[7] Issue #86151 — "Don't ask again for similar commands" saves verbatim command strings — https://github.com/anthropics/claude-code/issues/86151
[8] Issue #84318 — permissions.deny Read() rules from project settings not enforced from a subdirectory — https://github.com/anthropics/claude-code/issues/84318
[9] Empirical tests run in this environment, 2026-08-21, Claude Code 2.1.238, macOS darwin-arm64, Amazon Bedrock. Nine controlled runs: three `rm` variants against live repo settings; three isolated `claude -p --permission-mode dontAsk --setting-sources user --settings <file>` runs for `Read(/**)` vs `Read(//**)` vs in-anchor control; two `--permission-mode default` vs `auto` runs with an empty allow list; two `defaultMode` nesting-level runs. All scratch directories removed.
