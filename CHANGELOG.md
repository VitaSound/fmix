
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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

### TODO
- Fix compatibility with GForth installed via snap (cwd and project path detection).

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
 