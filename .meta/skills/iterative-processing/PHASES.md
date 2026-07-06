# Iterative Processing - Pattern Structure

**Source**: Official Claude Code batch processing patterns

**Note on Phase Count**: This pattern has 4 main phases. The core loop (Load → Process → Validate → Accumulate) repeats for each item, but the phases themselves represent the overall structure. Don't add unnecessary phases - this pattern is intentionally simple.

---

## Progress Tracking

Copy this checklist and update as you work:

```
Iterative Processing Progress:
- [ ] Phase 1: Initialize (identify items, set up tracking)
- [ ] Phase 2: Process Loop (for each item: load → process → validate → accumulate)
- [ ] Phase 3: Review Results (analyze cumulative findings)
- [ ] Phase 4: Generate Report (summarize and present results)

Current item: [N] of [total]
```

---

## Phase 1: Initialize

**Objective**: Identify all items to process and set up tracking structures.

**Actions**:
1. Identify the source of items (directory, list, database, API, etc.)
2. Count total items to process
3. Set up tracking structure (checklist, progress counter, results accumulator)
4. Establish success criteria for individual items
5. Determine progress reporting frequency (every N items)

**Output**: 
- List of all items to process
- Total count
- Progress tracking structure initialized
- Processing plan defined

**Validation Checkpoint**:
- [ ] All items identified and accessible
- [ ] Total count confirmed
- [ ] Tracking structure ready
- [ ] Success criteria clearly defined

**Questions to Ask User**:
- "I found [N] items to process. Should I proceed with all of them or exclude some?"
- "How often should I provide progress updates? (e.g., every 5 items, every 10 items)"
- "Should I pause for review at any checkpoint, or process all items continuously?"

---

## Phase 2: Process Loop

**Objective**: Process each item consistently using the defined pattern.

**For Each Item**:

### Step 2.1: Load
1. Retrieve the item (read file, fetch record, load document)
2. Extract relevant context or metadata
3. Verify item is valid and processable
4. If item is invalid or inaccessible, log error and skip to next item

### Step 2.2: Process
1. Apply the defined processing logic consistently
2. Transform, analyze, or generate as specified
3. Maintain consistent structure across all items
4. If processing fails, log error and attempt recovery or skip

### Step 2.3: Validate
1. Check output meets defined success criteria
2. Verify required elements are present
3. Validate format, structure, or content as specified
4. If validation fails, mark item for review or reprocessing

### Step 2.4: Accumulate
1. Add successful result to collection
2. Update progress counter
3. Log any issues or errors
4. If progress reporting threshold reached, provide update

### Step 2.5: Progress Update (periodic)
- Report items completed vs. total
- Report success rate so far
- Report any issues encountered
- Estimate remaining time (if applicable)

**Output**: 
- Processed results for current item
- Updated progress counter
- Error log (if issues occurred)
- Progress report (if threshold reached)

**Validation Checkpoint** (per item):
- [ ] Item loaded successfully
- [ ] Processing completed without errors
- [ ] Output validated against criteria
- [ ] Result added to accumulator

**Validation Checkpoint** (periodic, e.g., every 10 items):
- [ ] Success rate acceptable (e.g., > 90%)
- [ ] No systematic errors emerging
- [ ] Processing time reasonable
- [ ] Ready to continue or need adjustment

**Questions to Ask User** (when issues arise):
- "Item [name] failed validation: [reason]. Should I: (1) Skip it, (2) Try a different approach, (3) Pause for guidance?"
- "I'm seeing a pattern of failures: [description]. Should I adjust the processing approach?"
- "Progress is at [N]%. Everything looks good so far. Continue to completion?"

---

## Phase 3: Review Results

**Objective**: Analyze cumulative results to identify patterns, trends, or issues.

**Actions**:
1. Review all successful results
2. Analyze results that failed or needed adjustment
3. Identify patterns across items:
   - Common characteristics
   - Frequent issues
   - Outliers or anomalies
   - Distribution or trends
4. Calculate summary statistics:
   - Total processed
   - Success rate
   - Error rate and types
   - Time per item (if relevant)
5. Identify any systemic issues that should be addressed

**Output**:
- Summary statistics (counts, rates, distributions)
- Pattern analysis (commonalities, trends)
- Issue categorization (types of failures, frequencies)
- Recommendations (if applicable)

**Validation Checkpoint**:
- [ ] All items accounted for (processed + skipped + errors = total)
- [ ] Patterns identified and documented
- [ ] Issues categorized and explained
- [ ] Success rate meets expectations or reasons for variance clear

**Questions to Ask User**:
- "I found [N] items succeeded, [N] failed. The common failure reason is [X]. Should I reprocess the failures?"
- "I noticed [pattern] across [percentage] of items. Is this expected?"
- "Success rate is [X]%. Is this acceptable for your needs?"

---

## Phase 4: Generate Report

**Objective**: Create comprehensive summary of processing results.

**Actions**:
1. Structure report with clear sections:
   - Executive summary (high-level results)
   - Processing statistics (counts, rates, times)
   - Successful items (list or summary)
   - Failed items (with reasons)
   - Patterns identified
   - Recommendations (if applicable)
2. Format report appropriately (markdown, table, list, etc.)
3. Include examples of processed items (if helpful)
4. Note any items requiring follow-up
5. Provide next steps or action items

**Output**: Comprehensive report covering:
```markdown
# [Processing Task] - Results Report

## Summary
- Total items: [N]
- Successfully processed: [N] ([percentage]%)
- Failed/skipped: [N] ([percentage]%)
- Processing time: [duration]

## Successful Items
[List or summary of successfully processed items]

## Failed Items
[List with failure reasons]

## Patterns Identified
[Key patterns or trends across items]

## Recommendations
[If applicable]

## Next Steps
[Action items or follow-up needed]
```

**Validation Checkpoint**:
- [ ] Report includes all required sections
- [ ] Statistics are accurate
- [ ] All items accounted for
- [ ] Patterns clearly explained
- [ ] Next steps are actionable

---

## Success Criteria

Iterative processing is complete when:
- ✅ All items processed or explicit skip decision made for each
- ✅ Results validated and accumulated
- ✅ Patterns across items identified
- ✅ Comprehensive report generated
- ✅ User confirms results meet expectations

---

## Error Handling Patterns

### Item Loading Fails
**Pattern**: Single item cannot be accessed or loaded

**Response**:
1. Log the error with item identifier and specific error
2. Add to failed items tracking list
3. Skip to next item (don't halt entire batch)
4. Continue processing remaining items
5. Include in final report with failure reason

### Processing Fails for One Item
**Pattern**: Item loads successfully but processing encounters error

**Response**:
1. Attempt simple retry (once) in case of transient issue
2. If retry fails, log the processing error
3. Add to failed items list with error details
4. Continue with remaining items (isolated failure shouldn't stop batch)
5. Report at end for potential reprocessing or investigation

### Systematic Failures (> 20% failure rate)
**Pattern**: Multiple items failing with similar or related errors

**Response**:
1. Pause processing (don't continue if approach is fundamentally broken)
2. Report pattern to user with specific error details
3. Ask: Should I adjust processing approach, skip problematic pattern, or stop entirely?
4. Wait for user guidance before proceeding
5. If adjustment suggested, apply to remaining items

**Why pause**: Continuing with broken approach wastes processing time and may corrupt results

### Validation Fails
**Pattern**: Item processes successfully but output doesn't meet validation criteria

**Response**:
1. Mark item as "needs review" (not fatal failure)
2. Include in report with specific validation failure details
3. Continue processing (validation issues don't prevent processing remaining items)
4. Provide list of validation failures for manual review
5. Let user decide if validation failures need reprocessing

**Validation failures vs. Processing failures**: Validation failures mean "item processed but output questionable," processing failures mean "couldn't complete processing"

---

## Common Mistakes to Avoid

**DON'T**:
- Process items in random order if order matters - If there are dependencies, this isn't the right pattern
- Skip error logging - Always track what failed and why
- Ignore patterns of failures - Systematic issues should trigger review
- Continue processing if > 50% are failing - Stop and reassess approach
- Report only at the end for large batches - Provide periodic progress updates

**DO**:
- Maintain consistent processing logic across all items
- Log both successes and failures
- Provide progress updates for batches > 10 items
- Validate each item's output before accumulating
- Review cumulative results for patterns

---

## Adaptation for Different Scales

### Small Batch (< 10 items)
- Process all items
- Single report at end
- Simple checklist tracking

### Medium Batch (10-50 items)
- Progress update every 10 items
- Checkpoint at 50% for review option
- Categorized error reporting

### Large Batch (50-500 items)
- Progress updates every 20-50 items
- Multiple checkpoints
- Batch statistics (items/minute)
- Option to pause/resume

### Very Large Batch (500+ items)
- Consider sub-batch approach (process in groups of 100)
- Sub-batch reports
- Aggregate statistics
- Systematic error monitoring

---

**Version**: 1.0  
**Pattern Type**: Iterative batch processing  
**Complexity**: Simple core pattern, scales with batch size  
**Estimated Duration**: Depends on item count and processing complexity
