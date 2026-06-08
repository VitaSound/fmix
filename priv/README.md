# <name>

Forth package created with [FMix](https://github.com/VitaSound/fmix).

## Dependencies

```bash
fmix packages.get
```

## Usage

```forth
require ./<name>.4th
```

## Tests

```bash
fmix test
```

## Quality gate

Run the full check pipeline before push (requires `flint` and `fcov` on `PATH`):

```bash
fmix check --stage all
```

Install git hooks so `fmix check` runs automatically:

```bash
fmix hook install --stage all
fmix hook uninstall --stage all   # remove only hooks installed by fmix
```

Stages: `pre-commit` (test + flint), `pre-push` (+ fcov with optional `--fail-under`).
