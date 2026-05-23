
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Changed
- `bin/fmix`: only manipulates the terminal when stdout *is* a tty.
  Previously, when output was captured (`out=$(fmix …)`) the bracketed-
  paste reset escape leaked into the captured string as literal text
  `[?2004l`.
- `bin/fmix`: aligned with the shared launcher pattern used by
  `bin/flint` (and any future `bin/fcov`): `$<TOOL>_HOME`,
  `$<TOOL>_CMD`, `$<TOOL>_ARG`. The legacy `FMIX_PARAM` env var is
  still honoured for back-compat.
- `bin/fmix` header documents the recommended `~/.bashrc` snippet:
  `export PATH="$HOME/fmix/bin:$HOME/flint/bin:$HOME/fcov/bin:$PATH"`.
- `package.4th`: re-ordered to keep mandatory fields first, added
  `tags`, removed commented-out example dependency lines that were
  noise.
- README: links into the VitaSound tooling family (flint, ttester,
  fenum), new `Install` section with `~/.bashrc` snippet.

### Added
- `README.ru.md` — full Russian translation of the README.

### TODO
- Fix compatibility with GForth installed via snap (cwd and project path detection).
- For `dependencies fmix <ver>` (and future fcov/flint), skip the
  attempt to fetch from theforth.net — the entry exists purely for the
  version-check; the actual install is via the bin launcher.

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
 