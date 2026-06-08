# fmix — agent instructions

Forth package/build tool: scaffolding, dependency fetching, test runner. Umbrella for the VitaSound Forth toolchain ([feco](https://github.com/VitaSound/feco) catalog, [frules](https://github.com/VitaSound/frules) for coding rules).

Related tools: **flint** (lint), **fcov** (coverage), **fsemver** (version pins), **fmcp** (MCP bridge).

## Before commit

Use **`fmix check`** (or git hooks via **`fmix hook install`**) instead of running test/flint/fcov manually.

| Stage | Steps |
|-------|-------|
| `pre-commit` | `fmix test`; `flint lint . --strict --project-only` |
| `pre-push` | above + `fcov run fmix test --strict`; `fcov report --fail-under N` (optional) |

```bash
fmix check --stage pre-commit
fmix check --stage pre-push --fail-under 40   # optional threshold
fmix hook install --stage all
```

Requires **flint** and **fcov** on `PATH` (`FLINT_HOME`, `FCOV_HOME`). Missing tool → exit 1 with `[ERROR]`.

### flint

- **Role:** duplicate `: word` scan; `--strict` → exit 1 on warnings; `--project-only` skips `forth-packages/`.
- **Default (no flags):** warn-only, exit 0.
- **Version pin:** `key-value flint ~> 0.3` in `package.4th`.

### fcov

- **Role:** definition coverage during tests; `run --strict` propagates test failure; `report --fail-under` enforces threshold.
- **Version pin:** `key-value fcov ~> 0.3` in `package.4th`.
- **Artifacts:** `.fcov/` is gitignored.

### MCP equivalents (preferred)

| Step | MCP tool |
|------|----------|
| Full gate | `fmix_check` (`stage`, optional `fail_under`, `no_flint`, `no_fcov`) |
| Tests only | `fmix_test` |
| Lint only | `flint_lint` (optional `strict`, `project_only`) |
| Coverage | `fcov_run` → `fcov_report` |

Do **not** skip the quality gate before commit when MCP **vitasound-forth** is connected.

## Quality workflow

```text
fmix packages.get   # if package.4th or deps changed
fmix check --stage all
```

MCP: `fmix_packages_get` → `fmix_check` (or `fmix_test` + `flint_lint` + `fcov_run`).

## MCP (preferred for agents)

Cursor MCP server: **`vitasound-forth`** (stdio bridge: [fmcp](https://github.com/VitaSound/fmcp)).

| MCP tool | Task |
|----------|------|
| `fmix_check` | quality gate (preferred before commit) |
| `fmix_packages_get` | `forth-packages/` after clone or deps change |
| `fmix_test` | unit tests only |
| `flint_lint` | lint only (`strict`, `project_only` optional) |
| `fcov_run` / `fcov_report` | coverage only |
| `mcp_ping` | health check between batch calls |

`project_root` = absolute path to **this** repo (e.g. `/home/sea/fmix`).

Full tool list: [fmcp/AGENTS.md](https://github.com/VitaSound/fmcp/blob/main/AGENTS.md).
