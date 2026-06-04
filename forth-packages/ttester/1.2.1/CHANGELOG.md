# Change Log

All notable changes to this VitaSound fork of ttester are documented here.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and
this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.2.1] - 2026-05-24

### Added
- `LICENSE` file (the source already named public domain, the file was
  just missing).
- `README.ru.md` — full Russian translation, including a new
  "Публикация на theforth.net" section with archive-format and
  versioning guidelines.
- README links into the VitaSound tooling family (fmix / flint /
  fcov / fsemver / fenum).
- `package.4th`: added `main`, `tags`, switched `license` to the
  hyphenated `public-domain` token, and declared
  `key-value fcov ~> 0.3` so this repo participates in
  ecosystem-wide coverage collection.
- `.gitignore` created (`build/`, `forth-packages/`, `.fcov/`).

## [1.2.0] - 2026-05-23

### Added

- `ttester-ext.4th` — extensions on top of upstream `ttester.4th`:
  - Predicates: `expect-true`, `expect-false`, `expect-eq`, `expect-not-eq`,
    `expect-depth`, `expect-stack-clean`, `expect-stack-balanced`,
    `expect-str-eq`.
  - Fixture hooks: deferred `test-setup` / `test-teardown` plus `TS{ ... }ST`
    block that runs them around a normal `T{ ... }T`.
  - All assertions route through ttester's vectored `ERROR`, so `#ERRORS`
    and `ERROR-XT` continue to work for both upstream `T{` and the new
    predicates.
- `tests/ttester_ext_test.4th` — covers every predicate (positive + negative
  case) and the fixture mechanism.
- `README.md`, `CHANGELOG.md`.

### Unchanged

- `ttester.4th` is kept identical to upstream so this fork can track future
  revisions from the Hayes / Anton Ertl line.

## [1.1.0]

Initial import (corresponds to upstream `ttester.fs` 1.1.0 as shipped via
fmix `forth-packages/ttester/1.1.0/`).
