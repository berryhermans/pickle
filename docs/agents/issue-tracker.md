# Issue tracker: GitHub

Track project work in this repository's GitHub Issues. Use the `gh` CLI from the repository so it can infer the remote.

## Common operations

- Create an issue with `gh issue create --title "..." --body "..."`.
- Read one with `gh issue view <number>`.
- List issues with `gh issue list`, adding state or label filters as needed.
- Comment with `gh issue comment <number> --body "..."`.
- Update labels with `gh issue edit <number> --add-label "..."` or `--remove-label "..."`.
- Close with `gh issue close <number>`.

Use GitHub Issues when a skill asks to publish work or retrieve a ticket. PRs are not part of the triage/request queue by default.
