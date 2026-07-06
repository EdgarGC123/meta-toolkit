# Plugin Development Guide

**Purpose**: How to create plugins that add capabilities to toolkits.

---

## What is a Plugin?

A **plugin** is a self-contained capability that can be added to any toolkit.

**Examples**:
- `email-composer`: Write emails in user's style
- `invoice-processor`: Extract data from invoices  
- `code-analyzer`: Parse and analyze code
- `doc-reader`: Extract information from documentation
- `decision-framework`: Structured decision-making

**Plugins provide**:
- Processing logic (optional Python/JS scripts)
- AI prompt templates
- Configuration options
- Documentation

---

## Plugin Structure

```
plugins/[plugin-name]/
├── README.md                    # What it does, how to use
├── CONFIG.md                    # Configuration options
├── processor.py                 # (Optional) Processing script
├── prompts/                     # AI prompt templates
│   ├── [step1].prompt.md
│   └── [step2].prompt.md
└── examples/                    # (Optional) Usage examples
    └── example.md
```

---

## Creating a Plugin

### Step 1: Define the Capability

**Ask**:
- What capability does this add?
- What problem does it solve?
- Who would use it?
- What are typical inputs/outputs?

**Example - Email Composer**:
```
Capability: Write emails in user's authentic style
Problem: Emails sound robotic or inconsistent
Users: Anyone who writes emails regularly
Inputs: Context, recipient, key points
Outputs: Draft email in user's style
```

### Step 2: Create Directory

```bash
mkdir -p .meta/plugins/my-plugin-name/{prompts,examples}
cd .meta/plugins/my-plugin-name
```

### Step 3: Write README.md

```markdown
# [Plugin Name]

**What it does**: [One sentence]

**When to use**: [Typical scenarios]

---

## Quick Start

```bash
# How to use this plugin
[Simple instructions]
```

---

## What This Plugin Provides

- [Capability 1]
- [Capability 2]
- [Capability 3]

---

## Integration

Add to your workflow:

1. [Step to integrate]
2. [Configuration needed]
3. [How to invoke]

---

## Prompts

This plugin provides:

- `prompts/[step1].prompt.md` - [What it does]
- `prompts/[step2].prompt.md` - [What it does]

---

## Configuration

See `CONFIG.md` for:
- [Setting 1]
- [Setting 2]

---

## Examples

See `examples/` for usage examples.
```

### Step 4: Write CONFIG.md

```markdown
# [Plugin Name] Configuration

**Purpose**: Configure plugin behavior.

---

## Required Settings

**[Setting Name]**: [Description]
- Options: [Values]
- Default: [Default value]

**[Setting Name]**: [Description]
- Options: [Values]
- Default: [Default value]

---

## Optional Settings

**[Setting Name]**: [Description]
- When to use: [Scenario]
- Default: [Default value]

---

## Examples

### Example 1: [Scenario]
```yaml
[setting1]: [value]
[setting2]: [value]
```

### Example 2: [Scenario]
```yaml
[setting1]: [value]
[setting2]: [value]
```
```

### Step 5: Create Processor (Optional)

Only if your plugin needs pre-processing:

```python
#!/usr/bin/env python3
"""
[Plugin Name] Processor

Purpose: [What this processes]
"""

def process(input_data, config):
    """
    Process input according to plugin logic.
    
    Args:
        input_data: Raw input
        config: Plugin configuration
        
    Returns:
        Processed output ready for AI
    """
    # Your processing logic
    pass

if __name__ == "__main__":
    # CLI interface
    pass
```

### Step 6: Create Prompt Templates

For each step the plugin supports:

```markdown
# [Step Name] Prompt

**Purpose**: [What this prompt accomplishes]

**When to use**: [Scenario]

---

## Prompt Template

```
[Your prompt that uses this plugin capability]

Context: {{CONTEXT}}
Input: {{INPUT}}

Instructions:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Output format:
[Describe expected output]
```

---

## Variables

- `{{CONTEXT}}`: [What to provide]
- `{{INPUT}}`: [What to provide]
- `{{SETTING_NAME}}`: [From CONFIG.md]

---

## Example Usage

Input:
```
[Example input]
```

Expected Output:
```
[Example output]
```
```

### Step 7: Add Examples

```markdown
# [Plugin Name] Examples

## Example 1: [Scenario]

**Context**: [Situation]

**Input**:
```
[Example input]
```

**Using**:
- Prompt: `prompts/[step].prompt.md`
- Config: [Settings used]

**Output**:
```
[Example output]
```

**Explanation**: [Why this works]

---

## Example 2: [Different Scenario]

[Same structure]
```

---

## Plugin Patterns

### Pattern 1: Processor + Prompts

**When**: Need to structure inputs before AI

```
plugin/
├── README.md
├── processor.py        # Structures input
├── prompts/
│   └── analyze.prompt.md    # AI analyzes structured data
└── CONFIG.md
```

**Example**: code-analyzer (parses code, AI explains)

---

### Pattern 2: Prompts Only

**When**: AI can work with raw inputs

```
plugin/
├── README.md
├── prompts/
│   ├── draft.prompt.md
│   └── refine.prompt.md
└── CONFIG.md
```

**Example**: email-composer (no pre-processing needed)

---

### Pattern 3: Multi-Step

**When**: Complex capability needs multiple phases

```
plugin/
├── README.md
├── processor.py
├── prompts/
│   ├── step1.prompt.md
│   ├── step2.prompt.md
│   └── step3.prompt.md
├── CONFIG.md
└── examples/
```

**Example**: invoice-processor (extract → validate → format)

---

## Testing Your Plugin

### Manual Test

1. Create test toolkit
2. Add your plugin
3. Run through workflow
4. Verify outputs
5. Refine prompts/logic

### Checklist

- [ ] README explains clearly
- [ ] CONFIG documented fully
- [ ] Prompts tested with AI
- [ ] Examples show typical use
- [ ] Processor (if any) handles edge cases
- [ ] Tested by including it in a toolkit generation run

---

## Best Practices

### Do's

- ✅ Clear, focused capability (one thing well)
- ✅ Self-contained (no external dependencies if possible)
- ✅ Well-documented (README, CONFIG, examples)
- ✅ Tested prompts (actually run them)
- ✅ Reusable (not tied to one use case)

### Don'ts

- ❌ Too broad (do everything)
- ❌ Undocumented
- ❌ Untested prompts
- ❌ Complex dependencies
- ❌ Use-case specific

---

## Contributing Plugins

1. Create plugin following this guide
2. Test thoroughly
3. Add to `.meta/plugins/` in the accelerator
4. `/start-here` will detect it automatically on the next toolkit generation
5. Users can select it during discovery

---

## Examples to Study

When you build plugins and add them to `.meta/plugins/`, they become the examples others can study. The three patterns to aim for:
- Prompts-only (simplest — e.g. email-composer)
- Processor + prompts (e.g. code-analyzer)
- Multi-step (e.g. invoice-processor)

---

**Remember**: Plugins should be **self-contained capabilities** that can be mixed and matched in any toolkit.
