# ttester (VitaSound fork)

[Русская версия](README.ru.md)

A utility for testing Forth words, originally by John Hayes (1995, JHU/APL)
with subsequent revisions by Anton Ertl, David N. Williams, Krishna Myneni,
and C. G. Montgomery.

This is a fork maintained at https://github.com/VitaSound/ttester.

Part of the [VitaSound Forth tooling family](https://github.com/VitaSound):
[fmix](https://github.com/VitaSound/fmix) (build tool / package manager /
test runner), [flint](https://github.com/VitaSound/flint) (linter),
ttester (this fork), [fenum](https://github.com/VitaSound/fenum)
(universal containers).

## Upstream

The original `ttester.4th` is preserved verbatim so this fork can track
future upstream revisions. Upstream lives at
http://www.complang.tuwien.ac.at/cvsweb/cgi-bin/cvsweb/gforth/test/ttester.fs

## Layout

| File | What |
|------|------|
| `ttester.4th` | Hayes/Ertl `T{ ... -> ... }T` core, unmodified. |
| `ttester-ext.4th` | VitaSound extensions (this fork only). See below. |
| `tests/ttester_ext_test.4th` | Exercises every extension. |

## Core usage (upstream)

```forth
require ttester.4th

T{ 1 2 + -> 3 }T
T{ 1 2 3 SWAP -> 1 3 2 }T
```

Floating-point variants `R}T`, `XR}T`, `RXR}T` etc. work as documented in
the source of `ttester.4th`.

## Extensions (`ttester-ext.4th`)

```forth
require ttester.4th
require ttester-ext.4th
```

### Predicates

| Word | Stack | Asserts |
|------|-------|---------|
| `expect-true`  | `f --` | `f <> 0` |
| `expect-false` | `f --` | `f = 0` |
| `expect-eq`    | `a b --` | `a = b` |
| `expect-not-eq` | `a b --` | `a <> b` |
| `expect-depth` | `n --` | depth below `n` equals `n` |
| `expect-stack-clean` | `--` | `DEPTH = 0` |
| `expect-stack-balanced` | `--` | `DEPTH = START-DEPTH` (use inside `T{`) |
| `expect-str-eq` | `a1 u1 a2 u2 --` | `COMPARE = 0` |

All assertions route through ttester's vectored `ERROR`, so the existing
`#ERRORS` counter and `ERROR-XT` hook keep working unchanged.

### Fixtures

```forth
DEFER test-setup        ( default: noop )
DEFER test-teardown     ( default: noop )

TS{ ... }ST             \ like T{ ... }T but runs test-setup before
                        \ and test-teardown after the block
```

Example — remove `project-new` / `project-drop` boilerplate from every test:

```forth
:noname project-new ; is test-setup
:noname project-drop ; is test-teardown

TS{ project.name@ s" foo" expect-str-eq -> }ST
TS{ project.modules@ ulist-len 0 expect-eq -> }ST
```

Remember to reset the hooks (`' noop is test-setup ...`) at the end of a
test file when running in `fmix test --shared` mode, otherwise the next
file inherits them.

## License

`ttester.4th`: public domain (per the upstream header).
`ttester-ext.4th` and the rest of this fork: public domain.
