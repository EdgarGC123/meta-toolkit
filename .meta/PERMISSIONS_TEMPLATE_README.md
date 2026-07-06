# Permissions Templates

**Location**: `.meta/settings.*.json`  
**Purpose**: Modular permission sets that combine into a single `settings.json` for any generated toolkit  
**How it works**: Start with `settings.template.json` as the base. Layer in additional templates based on what the toolkit needs. Merge into one `settings.json` for the generated toolkit.

---

## The Four Templates

### `settings.template.json` — Base (always included)
Every toolkit gets this regardless of purpose. Covers day-one essentials: file navigation, git read operations, text processing, and environment info. Also includes all safety deny rules.

**Use for**: Any toolkit. This is always the starting point.

### `settings.research.json` — Research layer
Adds web access: `WebSearch`, `WebFetch`, `curl`, common research domains, and research-focused Skills (`research`, `update-config`).

**Use for**: Toolkits that need to search the web, fetch documentation, or perform external research.

### `settings.developer.json` — Developer layer
Adds code execution and deployment capabilities: git write ops (`add`, `commit`, `push`), Python/pip/pytest/black/mypy, Azure CLI, AWS CLI, and file manipulation (`mkdir`, `cp`, `mv`, `touch`).

**Use for**: Toolkits that involve writing code, deploying to Azure/AWS, or running tests.

### `settings.diagnostic.json` — Diagnostic layer
Adds deep environment inspection tools: `ping`, `ps`, `df`, `du`, `dig`, `node/npm`, `tar`, `unzip`, `yq`, and read-only cloud CLI inspection commands.

**Use for**: Debugging sessions, infrastructure audits, or environments where you need to inspect system state without making changes.

---

## How to Combine

During toolkit generation, decide what the toolkit needs and build a single `settings.json` by merging the relevant templates.

**The merge rule**: Always start with `settings.template.json`. Add the `allow` entries from any additional templates. The `deny` rules come from the base only — do not duplicate them in layered files.

### Common combinations

**Docs / knowledge / research toolkit**:
```
Base + Research
```

**Code-heavy / automation toolkit**:
```
Base + Research + Developer
```

**Pure developer (no web research needed)**:
```
Base + Developer
```

**Infrastructure / debugging session**:
```
Base + Diagnostic
```

**Full environment** (research + build + debug):
```
Base + Research + Developer + Diagnostic
```

### Merge process

To produce the final `settings.json`:
1. Start with all `allow` entries from `settings.template.json`
2. Append `allow` entries from each additional layer — skip duplicates
3. Use `deny` rules from `settings.template.json` only
4. Write the merged result to `.claude/settings.json` in the generated toolkit

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      // base allows first, then research/developer/diagnostic as needed
    ],
    "deny": [
      // base deny rules only — never layer additional deny rules
    ]
  }
}
```

---

## Adding Project-Specific Allows

After merging templates, append any project-specific domain `WebFetch` rules or one-off commands to the allow list before writing `settings.json`. Example for a toolkit that needs access to specific vendor documentation:

```json
"WebFetch(domain:docs.vendor-a.com)",
"WebFetch(domain:api.vendor-b.com)",
"WebFetch(domain:support.vendor-c.com)"
```

Add these directly to the toolkit's `.claude/settings.json` allow list.

---

## What Goes in `settings.local.json`

`settings.local.json` is **never committed**. It holds only machine-specific paths for the current developer. Add it to `.gitignore` on every generated toolkit.

```json
{
  "permissions": {
    "allow": [
      "Read(//Users/your-username/path/to/project/**)",
      "Read(//tmp/**)"
    ]
  }
}
```

---

## Overlap Between Developer and Diagnostic Layers

`settings.developer.json` and `settings.diagnostic.json` share several entries intentionally:

- `az account show`, `az account list`, `az group list`, `az resource list`, `az functionapp list`, `az storage account list` - read-only Azure inspection is needed in both development workflows and diagnostic sessions
- `aws sts get-caller-identity`, `aws lambda list-functions` - same rationale for AWS
- `pytest --collect-only` - needed both for running tests (developer) and for inspecting test structure without running (diagnostic)

When merging both layers, the bootstrap script deduplicates by checking `if entry not in seen` before appending. No duplicates will appear in the final `settings.json`.

---

## Template Maintenance

When adding a new permission to a template:
1. Decide which layer it belongs to (base = everyone needs it, otherwise be specific)
2. Add to the correct template file
3. Update this README's section for that template
4. Update `.claude/settings.json` in any active toolkits that use that layer

---

## Related Files

- `settings.template.json` — Base layer (always included)
- `settings.research.json` — Research layer
- `settings.developer.json` — Developer layer
- `settings.diagnostic.json` — Diagnostic layer
- `PERMISSIONS_GUIDE.md` in individual toolkits — documents the merged result for that specific project
