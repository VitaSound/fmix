## FMix 0.4.1

Build tool for Forth packages on GForth 0.7.9 (Linux).

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

### Install

```bash
git clone https://github.com/VitaSound/fmix.git
cd fmix && git checkout 0.4.1
export FMIX_HOME="$PWD"
alias fmix='gforth "$FMIX_HOME/fmix.4th" -e'
```
