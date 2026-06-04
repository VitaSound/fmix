# FMix and VitaSound Forth tooling (AI context)

**Dialect:** Gforth ≥ 0.7.9. Forth style and stack rules: sibling repo [frules](../frules) (`AGENTS.md`, `rules/*.mdc`). Install into a project with `../frules/install.sh <project> gforth` when editing `.4th` sources.

## Ecosystem tools (console utilities)

All are **CLI + Gforth**, launched via `bin/<tool>` with `$<TOOL>_HOME` (default `$HOME/<tool>`) and `$<TOOL>_CMD` / `$<TOOL>_ARG` env vars. Do **not** invent ad-hoc `gforth -e` build flows when these tools apply.

| Tool | Repo | Role |
|------|------|------|
| **fmix** | [fmix](https://github.com/VitaSound/fmix) | Package scaffold (`fmix new`), deps (`fmix packages.get`), tests (`fmix test`) |
| **flint** | [flint](https://github.com/VitaSound/flint) | Lint duplicate `: word` defs across `.4th` trees; **exit code always 0** — scan output for `[WARN]` |
| **fcov** | [fcov](https://github.com/VitaSound/fcov) | Coverage: `fcov run` then `fcov report` (`--format json` for machines) |
| **fmcp** | [fmcp](https://github.com/VitaSound/fmcp) | MCP stdio bridge (`fmcp serve`) exposing fmix/flint/fcov to Cursor |
| **fjson** | [fjson](https://github.com/VitaSound/fjson) | Minimal JSON write + read-lite for MCP NDJSON (`fjson.key-string`, `fjson.emit`, …) |
| **fsemver** | [fsemver](https://github.com/VitaSound/fsemver) | Semver matching for `key-value fmix ~> X.Y` pins (vendored or git dep) |
| **fenum** | [fenum](https://github.com/VitaSound/fenum) | Generic container/list helpers (used by flint, others) |

Related: [ttester](https://github.com/VitaSound/ttester) (tests), [f](https://github.com/VitaSound/f) (compat layer).

## Typical workflow in a Forth package

1. `fmix packages.get` — fetch `forth-packages/` from `package.4th`
2. `flint` — optional duplicate-definition pass
3. `fmix test` — `*_test.4th` under `tests/`
4. `fcov run` / `fcov report` — when coverage is requested

## `package.4th` conventions

- Pin runtime tools: `key-value fmix ~> 0.7`, `key-value flint ~> 0.2`, `key-value fcov ~> 0.3`
- Library deps: `key-list dependencies <name> git <url> tag <ver>`
- `fmix new` scaffolds defaults (fmix/flint/fcov pins + fsemver, fenum, ttester, f)

## MCP (Cursor)

Configure stdio server **fmcp** (not embedded in fmix/flint/fcov):

```json
{
  "mcpServers": {
    "vitasound-forth": {
      "command": "fmcp",
      "args": ["serve"],
      "env": {
        "FMIX_HOME": "/path/to/fmix",
        "FLINT_HOME": "/path/to/flint",
        "FCOV_HOME": "/path/to/fcov",
        "PATH": "/path/to/fmix/bin:/path/to/flint/bin:/path/to/fcov/bin:/path/to/fmcp/bin:..."
      }
    }
  }
}
```

Use MCP tools from fmcp when available; otherwise the same commands in the shell from the package root.

## This repo (fmix)

- Entry: `fmix.4th`, launcher `bin/fmix`
- Templates for `fmix new`: `priv/`
- Tests: `fmix test`, shell integration under `tests/`
- Releasing: see README § Releasing
