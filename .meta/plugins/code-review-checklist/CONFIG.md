# Code Review Checklist — Configuration

## Optional Settings

**TEAM_FOCUS**  
Categories your team cares most about. These get more items in the generated checklist.  
Example: `security, performance` or `tests, breaking-changes`  
Default: balanced across all categories

**CHANGE_TYPE**  
Helps the prompt skip irrelevant categories. Optional — the prompt auto-detects if not set.  
Options: `feature` | `bugfix` | `refactor` | `config` | `dependency-update` | `migration`

## Notes

- The prompt produces 15–20 items by default. Setting TEAM_FOCUS toward 1–2 categories will concentrate items there.
- Providing CHANGE_TYPE improves relevance — a CSS change will skip security and DB migration checks automatically even without it, but explicit typing helps for ambiguous changes.
