# Ticket Parser — Configuration

## Optional Settings

**TEAM_AC_FORMAT**  
Your team's preferred AC style. Default: `auto-detect`  
Options: `given-when-then` | `checklist` | `done-when` | `auto-detect`

**TICKET_SOURCE**  
The ticket system this ticket came from. Optional — used for field label hints.  
Options: `jira` | `linear` | `github` | `other`

## Notes

- All settings are optional. The plugin works without any configuration.
- `auto-detect` handles all four AC formats. Set explicitly only if your team uses one format consistently and auto-detect is producing wrong results.
- If you use a custom AC format not listed above, describe it in the prompt using the `TEAM_AC_FORMAT` variable override.
