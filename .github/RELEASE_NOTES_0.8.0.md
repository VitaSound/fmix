# fmix 0.8.0 — quality gate

## Highlights

- **`fmix check`** — one command for test + flint + fcov (by stage).
- **`fmix hook install`** — wire pre-commit / pre-push hooks automatically.

## Commands

```bash
fmix check --stage pre-commit          # test + flint --strict --project-only
fmix check --stage pre-push            # + fcov run/report (--fail-under optional)
fmix hook install --stage all
fmix hook uninstall --stage all
```

## Requirements

- **flint 0.3+** (`--strict`, `--project-only`) and **fcov 0.3.2+**
  (`run --strict`, `report --fail-under`) for the full pipeline.
- Set `FLINT_HOME` / `FCOV_HOME` (or PATH) like other VitaSound CLI tools.

## CI

Workflow runs on **`main`** only. Self-check uses `fmix check --no-flint` because
strict lint on fmix's own test fixtures reports intentional duplicate words.
