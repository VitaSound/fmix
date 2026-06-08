
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### TODO
- Fix compatibility with GForth installed via snap (cwd and project path detection).

## [0.8.0] - 2026-06-08

### Added
- **`fmix check`** — quality gate with stages `pre-commit` (test + flint),
  `pre-push` (+ fcov), and `all`; flags `--no-flint`, `--no-fcov`,
  `--fail-under N`.
- **`fmix hook install|uninstall`** — git hooks calling `fmix check`;
  idempotent install; uninstall only removes hooks with `# vitasound-fmix-hook`.
- `fmix_check.4th`, `fmix_check_config.4th`, `fmix_hook.4th`; hook templates
  under `priv/hooks/`.
- Tests: `fmix_check_test.4th`, `fmix_hook_test.4th`,
  `check_integration_test.sh`.
- Scaffold: Quality section in `priv/README.md`; commented `package.4th`
  examples for check config.

### Changed
- `package.4th`: version **0.8.0**; pin `flint ~> 0.3`.
- CI: triggers only on `main`; smoke `fmix check --no-flint --no-fcov`.
- Default branch is **`main`** (migration complete).

## [0.7.3] - 2026-06-08

### Added
- `tests/fmix_integration_test.4th` — fcov-visible integration (version-check
  fixtures, `packages.get` self-dep, `fmix new`, `fmix version`) raising
  definition coverage from ~44 % to ~75 % under `fcov run fmix test`.
- `.github/scripts/update-cov-badge.sh` — refresh Cov shields.io URLs from
  `fcov report --format json`.
- Cov badge in `README.md` / `README.ru.md`; Releasing checklist step for
  updating the badge after coverage runs.

### Changed
- CI: checkout fcov 0.3.0, run `fcov run` after tests, update Cov badge in
  README when coverage drifts.

## [0.7.2] - 2026-05-24

### Added
- `package.4th`: declare `key-value fcov ~> 0.3` (ecosystem-wide
  coverage participation) and `key-list fcov-exclude priv` /
  `tests/fixtures` so fcov reports the fmix codebase itself, not its
  scaffold templates or fixture projects. Current baseline on
  `fcov run fmix test`: 42/94 (44 %) — most uncovered code lives in
  `fmix_deps_git` and `fmix_new`, which are exercised by black-box
  `.sh` integration tests invisible to fcov.
- `.gitignore`: ignore `.fcov/` runtime artefacts (build/ already
  was, forth-packages/ stays tracked because it vendors fsemver).

## [0.7.1] - 2026-05-24

### Changed
- **Version-requirement engine extracted to fsemver.** The parser,
  matcher, semver-cmp and operator constants previously living inline
  in `fmix_version_check.4th` are now provided by the standalone
  [fsemver 0.1.0](https://github.com/VitaSound/fsemver) package,
  vendored under `forth-packages/fsemver/0.1.0/` and declared in
  `package.4th`. flint 0.2.1 and any future tool (fcov, …) share the
  same code path now — no more cut-and-paste drift between tools.
- `fmix_version_check.4th` shrinks from ~230 lines to ~125 (only the
  project-side `package.4th` mini-parser, the captured requirement
  string, the error messages, and `fmix.assert-min-version` itself).
- Operator coverage widens transparently: `>=`, `==`, `>`, `<`, `<=`
  are accepted in `key-value fmix <req>` in addition to `~>` and bare
  `X.Y.Z` (these were always going to be a small follow-up; you get
  them now for free via fsemver).

### Added
- `forth-packages/fsemver/0.1.0/` — committed vendored copy of fsemver
  so a fresh `git clone` of fmix runs without first needing to
  `fmix packages.get` (which would itself require fmix to work).
- `key-list dependencies fsemver git https://github.com/VitaSound/fsemver tag 0.1.0`
  in `package.4th` so the dependency is formally tracked and a future
  `fmix packages.get` can re-pull it.

### Notes
- No API changes for end users. Projects using
  `key-value fmix ~> 0.7` (or `~> 0.7.0`, `>= 0.7.0`, etc.) continue
  to work; legacy `key-list dependencies fmix …` still errors with the
  same migration hint.
- `tests/fmix_version_check_test.4th` is now a thin smoke-test (6
  assertions) that just verifies fsemver is reachable from fmix's load
  chain. The full 71-case operator truth-table lives in
  `forth-packages/fsemver/0.1.0/tests/fsemver_test.4th`.

## [0.7.0] - 2026-05-24

### Breaking
- **Runtime requirement on fmix is no longer expressed as a library
  dependency.** Pre-0.7.0 the convention was
  ```
  key-list dependencies fmix 0.6.0
  ```
  which was semantically wrong (fmix is a tool, not a library on
  theforth.net) and caused `fmix packages.get` to ask theforth.net for
  a package called `fmix` (HTTP 500). 0.7.0 introduces an Elixir/Hex
  style runtime key:
  ```
  key-value fmix ~> 0.7        \ accepts >=0.7.0  and  <1.0.0
  key-value fmix ~> 0.7.2      \ accepts >=0.7.2  and  <0.8.0
  key-value fmix 0.7.0         \ bare, accepts >=0.7.0 (no upper bound)
  ```
  Projects still using the old `key-list dependencies fmix …` form are
  rejected at command entry with a clear migration error pointing at
  the new syntax. There is no automatic conversion — projects need a
  one-line edit in `package.4th`.

### Added
- `fmix_version_check.4th`: requirement parser & matcher.
  - Operators supported: `~>` (Hex-style "pessimistic", upper bound
    derived from how many components were given) and bare `X.Y.Z` (=
    `>= X.Y.Z`, no upper bound).
  - `fmix.parse-req ( a u -- op ma mi pa valid? )` — parses a
    requirement string into op + 3-part version + valid? flag.
  - `fmix.req-matches? ( rma rmi rpa rop  sma smi spa -- f )` —
    true iff installed self-version satisfies the requirement.
  - 38 unit tests in `tests/fmix_version_check_test.4th` cover parse
    success, partials, whitespace, garbage, and the full matcher
    truth-table for all three operators.
- `tests/fixtures/{needs_future_fmix,legacy_fmix_dep,bare_fmix_req,invalid_fmix_req,self_dep_only}/`
  cover the canonical scenarios end-to-end through the bash launcher.
- `tests/version_check_integration_test.sh` rewritten: 7 OK lines
  exercising rejection (~> 99.0), legacy form, malformed requirement,
  and success path.

### Changed
- `fmix_packages_get.4th`: kept the tool self-dep skip (`fmix`,
  `flint`, `fcov`) as a silent defense-in-depth — version_check now
  errors out first, but the skip ensures we *never* attempt to fetch
  these names from theforth.net even via an unusual codepath.
- `bin/fmix`: only manipulates the terminal when stdout *is* a tty.
  Previously, when output was captured (`out=$(fmix …)`) the bracketed-
  paste reset escape leaked into the captured string as literal text
  `[?2004l`.
- `bin/fmix`: aligned with the shared launcher pattern used by
  `bin/flint` (and any future `bin/fcov`): `$<TOOL>_HOME`,
  `$<TOOL>_CMD`, `$<TOOL>_ARG`. The legacy `FMIX_PARAM` env var is
  still honoured for back-compat.
- `bin/fmix` header documents the recommended `~/.bashrc` snippet —
  one separate `export PATH="$HOME/<tool>/bin:$PATH"` line per tool,
  so each can be installed / removed independently of the others.
- `package.4th`: re-ordered to keep mandatory fields first, added
  `tags`, removed commented-out example dependency lines that were
  noise. Dropped the old self-pin entry — fmix doesn't pin itself.
- README / README.ru: new `Install` section with `~/.bashrc` snippet,
  rewritten version-pinning section explaining `~>` semantics,
  links into the VitaSound tooling family (flint, ttester, fenum).

### Migration

Old (0.5.x – 0.6.x):
```forth
forth-package
    key-list dependencies fmix 0.6.0
end-forth-package
```

New (0.7.0+):
```forth
forth-package
    key-value fmix ~> 0.7
end-forth-package
```

## [0.6.0] - 2026-05-24

### Added

- `fmix_version_check.4th`: read the project's `./package.4th` at load
  time, find a `key-list dependencies fmix <version>` entry, and bail
  out with a clear error if the installed fmix is older than what the
  project asks for. Runs at the entry of `fmix test` and
  `fmix packages.get` (project-scoped commands). `fmix version` and
  `fmix help` are deliberately exempt so you can still introspect the
  tool when it refuses to do work — that's how you find out what to
  upgrade.
- Supported dependency forms (matched against name `fmix`):
  - `key-list dependencies fmix 0.6.0`
  - `key-list dependencies fmix git <url> tag 0.6.0`
  The `git ... branch <name>` form has no version, so no check.
- Best-effort semver parser/comparator (`fmix.parse-semver`,
  `fmix.semver-cmp`). Tolerates missing/garbage components by collapsing
  them to 0 instead of crashing.
- `tests/fmix_version_check_test.4th` (unit tests for parse + cmp) and
  `tests/version_check_integration_test.sh` (drives a fixture project
  pinning `fmix 99.0.0` and asserts that `fmix test` / `packages.get`
  refuse to run while `fmix version` / `help` still work).

### Changed

- Tighten `fmix test` file filter from `_test.` to `_test.4th`. The
  looser pattern previously picked up files like
  `tests/version_check_integration_test.sh` and tried to feed them to
  gforth, producing spurious failures.

### Self-dependency

- fmix's own `package.4th` now declares
  `key-list dependencies fmix 0.6.0` — eats its own dog food.

## [0.5.1] - 2026-05-23

### Fixed
- `fmix test --isolated`: terminal garbage between subprocesses on WSL/xterm
  (`^[]11;rgb:0c0c/0c0c/0c0c^[\\…`). Each subprocess now runs with
  `TERM=dumb gforth … </dev/null`: with no tty stdin, gforth/readline cannot
  issue OSC 11 (background-colour query), so the terminal never replies into
  the parent shell's input buffer between tests.

### Changed
- Clearer `fmix help` for `test`: `[f]` → `[<test_file>]`, aligned columns.

## [0.5.0] - 2026-05-23

### Added
- `fmix test --isolated` (default) runs each `*_test.4th` in a fresh `gforth`
  subprocess. A failure (or a leaked stack / mutated global state) in one
  test file can no longer mask problems in the next file. This replaces the
  ad-hoc per-project bash runners that wrapped `gforth -e '… included bye'`.
- `fmix test --shared` keeps the legacy single-session behaviour for projects
  that intentionally exercise cross-test state (e.g. `project-drop` correctly
  freeing all heap structures across many tests).
- Flag parsing is done in `bin/fmix` (bash) and passed to Forth via
  `FMIX_TEST_ISOLATED=1|0`; unknown `--flags` after `test` are rejected with
  exit code 1.

### Changed
- **Default test mode is now `--isolated`.** Projects that rely on the
  cross-test shared session must explicitly use `--shared`.

### Fixed
- `fmix.exit` now actually exits with status 1: Gforth's `bye` ignores its
  TOS, so `1 bye` was equivalent to `bye` (status 0). Use `1 (bye)` instead.
  Without this fix, `fmix test` always returned 0 from the launcher even
  when individual tests failed — breaking CI.

## [0.4.4] - 2026-05-18

### Fixed
- Restore TTY after every command to prevent `0c0c` / `[?2004l` garbage on WSL prompts: single exit via `0 bye`, `bin/fmix` wrapper, `FMIX_CMD` env vars, and a short `/dev/tty` input-drain for queued terminal replies.
- Fix `fmix.restore-terminal` stack underflow: do not `drop` after `system` in GForth 0.7.9.
- Refactor command dispatch without `EXIT` so TTY restore always runs before exit.
- Fix `fmix` with no arguments: `bin/fmix` defaults to `help` instead of stack underflow after `-e`.
- Fix optional parameter in `fmix.read_args` when the command has no extra argument.
- Fix terminal garbage after `fmix new` and other commands: use `bin/fmix` launcher, restore TTY in shell and after `fmix.new`.
- Restore TTY after `fmix test`, `packages.get`, `version`, and `help`; reset bracketed-paste in `bin/fmix` before and after GForth.
- Use `fmix.exit` when `package.4th` is missing in `packages.get` (plain `EXIT` skipped TTY restore).

## [0.4.3] - 2026-05-17

### Fixed
- Restore the shell TTY after exit so prompts do not show terminal garbage such as `[?2004l` or `0c0c` (common on WSL and Windows).

### Changed
- Document a `fmix()` shell function with `stty sane` instead of a plain `alias` in README.
- Call `fmix.exit` (with TTY restore) on error paths in utilities and tests.

## [0.4.2] - 2026-05-17

### Added
- Document the release checklist in README (for maintainers and AI assistants).
- Create a GitHub Release automatically when a version tag is pushed.

### Changed
- Release workflow triggers on `git push` of version tags, not only manual `workflow_dispatch`.

## [0.4.1] - 2026-05-17

### Added
- GitHub Actions CI: build and install GForth 0.7.9 from source, then run `gforth fmix.4th -e version` and `gforth fmix.4th -e test`.

### Changed
- Replace the `TODO: Add description` placeholder in the new-project `README.md` template with a minimal starter guide.
- Resolve FMix internal files from `FMIX_HOME`, with `$HOME/fmix` as fallback.
- Resolve the current project directory with `get-dir` instead of the `PWD` environment variable.
- Keep project `package.4th` and dependencies in the directory where `fmix` is started.
- Load project `ttester` from `./forth-packages` when present, otherwise from `FMIX_HOME`.
- Document `FMIX_HOME` setup and project-local `./forth-packages` usage in README.

### Fixed
- Fix `fmix new` leaving `<name>` unsubstituted in `README.md` and `package.4th` because shell validation rejected the template marker in `sed`.
- Reject shell-metacharacters in package names, versions, paths, git refs, and URLs before running `cp`, `sed`, or `git` commands.
- Make `fmix test` return a non-zero exit code when tests fail.
- Fix failing sample tests and suppress duplicate utility definitions during test runs.
- Make failed system commands exit GForth with exit code `1` instead of `0`.
- Fix theforth.net installs writing to `forth-packages<name>` by using `./forth-packages/` as required by `f.4th`.
- Fix git `clone` not checking command status and reporting `Clone OK` after failures.
- Create parent directories before git `clone` into `./forth-packages/<name>/<version>`.
- Run git update steps with `&&` so a failed `fetch` does not continue with `checkout`.
- Set `GIT_TERMINAL_PROMPT=0` for non-interactive git dependency commands.
- Fix new-package test template to require `../forth-packages/...` from the `tests/` directory.

### Removed
- Remove the `dependencies_path_fmix` package option for shared FMix-level dependencies.

## [0.4.0] - 2026-01-21

Global refactory with helps by Google AI Gemini and QWen.code.

### Added
- refactory all functions: new, geps get, tests
- Command fmix test for all tests and one file with detect errors
- some changes when git update depends
- add utilities
- add tests for utilities and some logic
- read version from package and show help with start without parameters


## [0.3.4] - 2025-07-02

change example dependencies to git

## [0.3.3] - 2024-10-13

moved to VitaSound

## [0.3.2] - 2024-09-29
  
Update gforth version to 0.7.9. 

## [0.3.1] - 2024-05-03
  
Add tests feature
### Added
- Command fmix.test
 
## [0.3.0] - 2024-04-27
  
Global changes after implement of get https://theforth.net packages 
### Added
- Get dependencies from https://theforth.net
 
### Changed
  
- Changed 'deps' to 'forth-packages' for compatibility with https://theforth.net
- Change command `fmix deps.get` to `fmix packages.get`
- Patch of dependencies by default is `./forth-packages/` like https://theforth.net f.4th fget command
- For change default patch to fmix patch use key `key-value dependencies_path_fmix`
 
## [0.2.0] - 2024-04-25
  
Global changes after discussion in TG Forth group. https://t.me/ruforth
 
### Added
 
### Changed
  
- Changed concept 'fproject' to 'package' for compatibility with https://theforth.net
- Change logic `fmix new` from generate files to copy files from templates
- Some refactories

### Fixed
 
## [0.1.0] - 2024-04-24
 
### Added

- Released first version
   
### Changed
 
### Fixed
 