# Iterative Processing Skill

**Pattern**: Process multiple items consistently with accumulation and review

**Source**: Based on official Claude Code batch processing patterns and Tool Use best practices

---

## What This Skill Provides

A systematic approach for processing multiple items (files, records, tasks, entries) one at a time with consistent structure, progress tracking, error handling, and cumulative review.

This pattern ensures:
- **Consistency**: Every item processed the same way
- **Progress tracking**: Always know where you are in the batch
- **Error recovery**: Handle failures without losing progress
- **Cumulative analysis**: Identify patterns across all items

---

## When to Use

Use this skill when:
- Processing multiple files or documents (batch analysis)
- Reviewing records or entries (data validation, quality checks)
- Applying same analysis to multiple subjects (comparative review)
- Generating reports for multiple entities (personalized outputs)
- Need consistent treatment across all items (standardization)
- Batch operations where order doesn't create dependencies

**Do NOT use when**:
- Single item processing (no iteration needed)
- Items require completely different approaches (not a pattern)
- Strong dependencies between items (use workflow phases with explicit ordering)
- Items should be processed in parallel without accumulation (use different orchestration)

---

## How It Works

**Note on Item Count**: This pattern works for any number of items. The example structure below applies whether you have 5 items or 500. Adjust batch sizes and progress reporting based on scale.

### Core Loop Structure

For each item in the batch:
1. **Load** - Get the item and its context
2. **Process** - Apply consistent analysis/transformation  
3. **Validate** - Check the output meets criteria
4. **Accumulate** - Add to running results
5. **Progress update** - Report status periodically

After all items:
6. **Review** - Analyze cumulative results for patterns or issues
7. **Report** - Summarize findings across the entire batch

---

## Integration with Workflow

This skill applies within a workflow phase when that phase needs to handle multiple items:

```markdown
## Phase 3: Document Analysis

Apply iterative processing to all documents in input/:

1. Load item list (identify all files)
2. For each document:
   - Load content
   - Apply analysis pattern
   - Validate output
   - Accumulate results
   - Update progress (every 5 items)
3. Review cumulative findings
4. Generate summary report

Expected output: Analysis results for each document + patterns across all documents
```

---

## How to Apply This Pattern

This pattern is abstract and applies to any scenario where you have multiple items requiring consistent treatment. Here's how to think about applying it:

### Pattern Application Template

**Your workflow**: [Describe what you're processing]  
**Item definition**: [What constitutes one "item" in your batch]  
**Load step**: [How to retrieve/access each item]  
**Process step**: [What transformation/analysis to apply]  
**Validate step**: [What criteria determine success]  
**Accumulate step**: [How to collect results]  
**Review step**: [What patterns to look for across all items]  
**Output**: [What the final deliverable looks like]

### Generic Examples by Complexity

#### Simple Batch (few items, straightforward processing)
- **Items**: 10-20 items
- **Processing**: Single transformation or check per item
- **Validation**: Simple pass/fail criteria
- **Review**: Basic statistics (count, success rate)
- **Example pattern**: "Process each item in list, apply rule X, collect results"

#### Medium Batch (moderate items, multi-step processing)
- **Items**: 20-100 items
- **Processing**: Multiple checks or transformations per item
- **Validation**: Multi-criteria validation with severity levels
- **Review**: Pattern identification, categorization
- **Example pattern**: "For each item, extract data, transform, validate structure and content, categorize results"

#### Complex Batch (many items, sophisticated processing)
- **Items**: 100+ items
- **Processing**: Complex logic with conditional paths
- **Validation**: Comprehensive checks with error recovery
- **Review**: Statistical analysis, trend identification, outlier detection
- **Example pattern**: "Process large dataset, apply domain-specific rules, handle edge cases, identify systematic issues"

### Thinking About Your Use Case

When applying this pattern, ask:

1. **What am I iterating over?**
   - Files in a directory?
   - Records in a list?
   - Entries in a dataset?
   - Items in a collection?

2. **What's the same for every item?**
   - Same analysis applied to each
   - Same validation rules
   - Same output format
   - Same success criteria

3. **What might vary between items?**
   - Content complexity
   - Data completeness
   - Edge cases to handle
   - Processing time

4. **How do I know when one item is "done"?**
   - Specific validation criteria
   - Required fields present
   - Output format correct
   - No errors encountered

5. **What patterns should I look for across all items?**
   - Common characteristics
   - Frequent issues
   - Outliers or anomalies
   - Success/failure trends

---

## Pattern Variations

### Small Batch (< 10 items)
- Process all items, report at end
- Simple checklist tracking

### Medium Batch (10-50 items)  
- Report progress every 5-10 items
- Intermediate checkpoint after halfway

### Large Batch (50+ items)
- Report progress every 10-20 items
- Multiple checkpoints
- Consider pausing for user review midway

### Very Large Batch (500+ items)
- Break into sub-batches
- Summary reports per sub-batch
- Aggregate at end

---

## Integration with Other Skills

**Works well with**:
- **validation-pattern**: Validate each processed item
- **error-recovery**: Handle failures gracefully in batch processing

**Different from**:
- **research-synthesis**: That skill synthesizes across sources; this processes each independently
- **multi-step-analysis**: That skill goes deep on one subject; this goes broad across many

---

**Version**: 1.0  
**Created**: 2026-05-22  
**Applicable to**: Any workflow requiring consistent multi-item processing  
**Type**: Non-code pattern (works with or without programming)  
**Complexity**: Simple to Medium depending on validation requirements
