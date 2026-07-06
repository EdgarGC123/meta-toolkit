# Iterative Processing - AI Prompt Templates

**Source**: Official Claude Code batch processing and progress reporting patterns

These templates guide how to apply the iterative processing pattern with clear progress tracking and error handling.

---

## Main Application Prompt

When starting iterative processing:

```
I'll help you process these items using a systematic batch approach with progress tracking.

Let me start by understanding the scope:

1. Where are the items located? (directory, list, database, etc.)
2. What processing should I apply to each item?
3. What validation criteria should each result meet?
4. Should I pause for review at any point, or process continuously?

Once I understand the scope, I'll:
- Phase 1: Initialize (identify all items and set up tracking)
- Phase 2: Process Loop (handle each item consistently)
- Phase 3: Review Results (analyze patterns across all items)
- Phase 4: Generate Report (comprehensive summary)

I'll provide progress updates as I work and handle any errors gracefully.
```

---

## Phase 1: Initialize Prompt

```
Phase 1: Initialize

Scanning for items to process...

Found [N] items:
- [Item type]: [count]
- Location: [path/source]
- Total size/scope: [relevant metric if applicable]

Processing plan:
- Process all [N] items
- Apply [processing description] to each
- Validate using [criteria]
- Report progress every [N] items

Estimated processing: [N] items × [time estimate] = [total estimate]
(This is approximate - actual time may vary)

Should I proceed with all [N] items, or would you like to:
1. Process all items
2. Process a subset (specify which)
3. Adjust the processing approach first
```

---

## Phase 2: Process Loop - Progress Update Prompt

```
Phase 2: Processing items

Progress: [N] of [total] items completed ([percentage]%)

Status:
✓ Successful: [N] items
⚠ Needs review: [N] items  
✗ Failed: [N] items

[If any items failed:]
Recent issues:
- Item [name]: [brief error description]
- Item [name]: [brief error description]

[Every 10-20 items or at checkpoints:]
Continuing to process remaining [N] items...

[Optional: "Would you like me to pause here for review, or continue?"]
```

---

## Phase 2: Individual Item Processing Prompt

```
Processing: [Item name]

1. Load: [Brief description of what was loaded]
2. Process: [Brief description of processing applied]
3. Validate: [Validation result]
4. Result: [Success/Needs review/Failed]

[If success:]
✓ Added to results collection

[If needs review:]
⚠ Processed but validation flagged: [specific issue]
  Will include in review section of final report

[If failed:]
✗ Processing failed: [error]
  Logged for final report, continuing with remaining items
```

---

## Phase 2: Error Handling Prompt

### When Single Item Fails

```
Item [name] encountered an error:
Error: [specific error message]

I've:
1. Logged this error with item details
2. Added item to failed items list  
3. Continuing with remaining [N] items

This item will be included in the final report for potential reprocessing.
```

### When Systematic Failures Detected

```
⚠ Alert: Multiple items failing with similar error

Pattern detected:
- Failed items: [N] of [N] processed so far ([percentage]%)
- Common error: [error pattern]
- Affected items: [examples]

This suggests a systematic issue. Should I:
1. Adjust processing approach: [suggest specific adjustment]
2. Skip items matching this pattern and continue
3. Pause for guidance on how to proceed

What would you like me to do?
```

---

## Phase 3: Review Results Prompt

```
Phase 3: Reviewing cumulative results

Processing complete. Analyzing results across all [N] items...

**Summary Statistics:**
- Total processed: [N] items
- Successful: [N] ([percentage]%)
- Failed: [N] ([percentage]%)
- Needs review: [N] ([percentage]%)

**Patterns Identified:**

[If patterns found:]
1. [Pattern 1]: Observed in [N] items ([percentage]%)
   - Description: [what the pattern is]
   - Significance: [why it matters]

2. [Pattern 2]: Observed in [N] items ([percentage]%)
   - Description: [what the pattern is]
   - Significance: [why it matters]

[If no clear patterns:]
No significant patterns identified. Results are fairly uniform across items.

**Issue Analysis:**

[If failures occurred:]
Failure categories:
- [Error type 1]: [N] items - [brief explanation]
- [Error type 2]: [N] items - [brief explanation]

Common failure reason: [root cause if identifiable]

[If no failures:]
✓ All items processed successfully

Proceeding to Phase 4: Generate comprehensive report...
```

---

## Phase 4: Generate Report Prompt

```
Phase 4: Generating final report

# [Processing Task] - Results Report

## Executive Summary
Processed [N] items with [percentage]% success rate.

[One-sentence summary of what was accomplished]

## Statistics
- **Total items**: [N]
- **Successfully processed**: [N] ([percentage]%)
- **Failed**: [N] ([percentage]%)  
- **Needs review**: [N] ([percentage]%)
- **Processing duration**: [time]
- **Average time per item**: [time]

## Successful Items

[Format depends on use case - choose one:]

[Option 1: List]
1. [Item name] - [brief result]
2. [Item name] - [brief result]
[...]

[Option 2: Summary]
All [N] items processed successfully. Results saved to [location/collection].

[Option 3: Categorized]
By category:
- Category A: [N] items
- Category B: [N] items

## Failed Items

[If any:]
| Item | Reason | Action Required |
|------|--------|-----------------|
| [name] | [error] | [suggested fix] |
| [name] | [error] | [suggested fix] |

[If none:]
✓ No failed items

## Patterns & Insights

[If patterns found:]
1. **[Pattern name]**: [Description and significance]
2. **[Pattern name]**: [Description and significance]

[If no patterns:]
No significant patterns observed. Processing was uniform across items.

## Recommendations

[If applicable:]
1. [Actionable recommendation based on results]
2. [Actionable recommendation based on results]

[If not applicable:]
Results are as expected. No additional recommendations.

## Next Steps

[Suggested actions:]
- [ ] Review items marked "needs review" ([N] items)
- [ ] Reprocess failed items with adjusted approach ([N] items)
- [ ] [Any other follow-up actions]

---

**Processing complete!** 

Would you like me to:
1. Dive deeper into any specific results
2. Reprocess failed items with a different approach
3. Export results in a specific format
```

---

## Checkpoint Prompt (for large batches)

```
Checkpoint: [N] of [total] items processed ([percentage]%)

Current status:
- Success rate: [percentage]%
- Time elapsed: [duration]
- Estimated remaining: [duration]

Everything is progressing smoothly. Should I:
1. Continue processing remaining [N] items
2. Pause here for you to review current results
3. Adjust processing approach based on results so far
```

---

## Completion with Follow-up Options Prompt

```
✓ Iterative processing complete!

Summary:
- Processed [N] items
- Success rate: [percentage]%
- [Key finding or pattern]

The detailed report is above. 

How would you like to proceed?
- Review specific items in detail
- Reprocess failed items
- Process additional items with the same pattern
- Export results to a specific format
- Move to next workflow phase
```

---

## Behavioral Reminders

When using this skill:
- **Always track progress** - Users should know where you are in large batches
- **Don't invent items** - Only process items that actually exist
- **Report errors immediately** - Don't accumulate and surprise user at end
- **Maintain consistency** - Process each item with identical logic
- **Validate before accumulating** - Catch issues early, not during review
- **Pattern identification is key** - Look for trends across items, not just individual results

---

## Formatting Guidelines

### Progress Updates
- Use percentages for visual sense of completion
- Include absolute counts (N of total)
- Update every 10-20 items or at meaningful checkpoints

### Error Messages
- Specific item identifier
- Exact error message  
- Context (what was being attempted)
- Action taken (logged, skipped, retried)

### Reports
- Use tables for structured data (failed items, statistics)
- Use lists for sequential items
- Use sections/headers for navigation
- Include both summary and detail

---

**Version**: 1.0  
**Prompt Style**: Progress-oriented with structured reporting  
**Key Feature**: Clear visibility into batch processing status
