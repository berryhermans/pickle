## Agent skills

### Issue tracker

Issues and specs are tracked in GitHub Issues via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout: root `GLOSSARY.md` and `docs/adr/`. See `docs/agents/domain.md`.

### Pre-release data compatibility

Before the first `release/*` branch exists, treat persisted app data as disposable and implement the current data model without legacy migrations or compatibility handling. Add compatibility only when a ticket explicitly requires it. Once a `release/*` branch exists, treat persisted data as a compatibility contract and address migration requirements explicitly.
