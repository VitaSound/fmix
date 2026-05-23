# fmix
[![License](https://img.shields.io/badge/License-COPL-red.svg)](https://raw.githubusercontent.com/VitaSound/fmix/refs/heads/master/LICENSE)
[![Ver](https://img.shields.io/badge/Ver-0.5.1-green.svg)](https://github.com/VitaSound/fmix/releases/tag/0.5.1)

FMix is a build tool that provides tasks for creating, and testing Forth packages, managing its dependencies, and more.

```bash
$ fmix

FMix v0.5.1 is a build tool that provides tasks for creating, and testing Forth packages, managing its dependencies.
Usage: fmix <command> [args]
Commands:
   new <name>                                - Create new package
   packages.get                              - Install dependencies
   test [--isolated|--shared] [<test_file>]  - Run all *_test.4th in
                                               ./tests, or one given file.
                                               --isolated (default): each test
                                               in a fresh gforth process.
                                               --shared: single session for all.
   version                                   - Show version
```

### `fmix test` modes

| Mode | When to use |
|------|-------------|
| `--isolated` (default) | Every `*_test.4th` runs in its own `gforth` process. A failure / leaked stack / mutated global in one file cannot mask problems in another. This is the modern expectation for test runners and replaces ad-hoc per-project bash scripts like `gforth -e 's" tests/foo_test.4th" included bye'`. |
| `--shared` | All tests share one `gforth` session. Useful for stress-testing teardown words (e.g. `project-drop` correctly freeing heap structures across many tests). Treats cross-test state coupling as a feature, not a bug. |

Both modes return a non-zero exit code on failure. CI should normally use the default. |

Format of package description, as example:

`package.4th`

```forth
forth-package
    key-value name fmix
    key-value version 0.1.0
    key-value license COPL
    key-value description Forth build tool
    key-value main fmix.4th
    \ packages from git
    \ key-list dependencies <package_name> git <http-url> [branch|tag] <name>
    key-list dependencies ftest git https://github.com/UA3MQJ/ftest.git branch main
    key-list dependencies ftest git https://github.com/UA3MQJ/ftest.git branch special_branch
    key-list dependencies ftest git https://github.com/UA3MQJ/ftest.git tag 0.1.0
    \ packages from theforth.net
    \ key-list dependencies <package_name> <version>
    key-list dependencies f 0.2.4
end-forth-package
```

Packages stored to `./forth-packages`

### Allowed characters in `package.4th`

FMix validates names, versions, paths, git refs, and URLs before running
`cp`, `sed`, or `git`. This is a simple whitelist (not full shell quoting).

| Field | Allowed |
|-------|---------|
| Package name, version | `a-z`, `A-Z`, `0-9`, `_`, `.`, `-` |
| Path (internal) | same + `/`; `..` is rejected |
| Git URL | name chars + `:/=?%@` |
| Git ref (`branch` / `tag`) | path rules |
| Git type | only `branch` or `tag` |

Spaces, semicolons, `$`, backticks, pipes, and other shell metacharacters
are rejected with `[ERROR] Invalid ...` and exit code `1`.

```forth
require ./forth-packages/ftest/main/ftest.4th
```
This structure allows:

* to store all dependencies in one place
* to have the ability to work with different versions of one dependency.

Using dependencies in your packages

```forth
require ./forth-packages/ftest/main/ftest.4th
```

# Install

```bash
git clone https://github.com/VitaSound/fmix.git

    nano ~/.bashrc
    or
    nano ~/.zshrc

    export FMIX_HOME="$HOME/fmix"
    export PATH="$FMIX_HOME/bin:$PATH"
```

**Do not** use `alias fmix='gforth "$FMIX_HOME/fmix.4th" -e'` — it leaves the
terminal in a bad state (`0c0c`, `[?2004l` on the next prompt, common on WSL).

Use the launcher script (or a wrapper around it):

```bash
fmix() {
    "$FMIX_HOME/bin/fmix" "$@"
}
```

`bin/fmix` runs `stty sane`, resets bracketed-paste mode, and briefly drains
queued terminal input after every command.

`FMIX_HOME` points to the installed FMix directory. Commands such as
`packages.get` and `test` operate on the current project directory where
`fmix` is started.

# Use

create new package
```bash
  fmix new example
  cd example
```
get dependecies packages
```bash
  fmix packages.get 
```
Run tests
```bash
  fmix test
```

# Depends

GForth 0.7.9, linux, git, sed, cp.

WARNING! Do not use GForth from snap. Snap runs GForth in a confined
environment where the current working directory and filesystem paths may
not match the shell session. That breaks `new`, `packages.get`, and other
commands that rely on the project directory. Prefer `apt`, a local build
under `~/opt/gforth-0.7.9`, or a tarball install.

# Releasing

Checklist for a new version (e.g. `0.4.4`). Intended as maintainer notes and as
context for AI assistants helping with the repo.

1. **Implement changes** on `master` (features, fixes, docs).
2. **Update `CHANGELOG.md`**: move items from `[Unreleased]` into a new section
   `## [X.Y.Z] - YYYY-MM-DD`.
3. **Add release notes file**  
   `.github/RELEASE_NOTES_X.Y.Z.md` — copy the changelog section for that version
   (GitHub Release body is taken from this file).
4. **Bump version** in `package.4th` (`key-value version X.Y.Z`) and in `README.md`
   (badge URL and `FMix vX.Y.Z` in the help example).
5. **Commit and push** to `origin/master`:
   ```bash
   git add -A
   git commit -m "Release X.Y.Z."
   git push origin master
   ```
6. **Create and push an annotated tag** (triggers [Publish Release](.github/workflows/release.yml)):
   ```bash
   git tag -a X.Y.Z -m "FMix X.Y.Z"
   git push origin X.Y.Z
   ```
7. **Verify**: [Actions → Publish Release](https://github.com/VitaSound/fmix/actions/workflows/release.yml)
   should succeed; check [Releases](https://github.com/VitaSound/fmix/releases).

If the workflow fails with `Missing .github/RELEASE_NOTES_X.Y.Z.md`, add that file
on `master`, push, then re-run the workflow manually (**Run workflow**, enter the tag)
or delete and re-push the tag (only if the release was not published yet).

Manual fallback (no tag hook):

```bash
gh release create X.Y.Z --title "FMix X.Y.Z" --notes-file .github/RELEASE_NOTES_X.Y.Z.md
```

# Status

- [x] Create package
- [x] Get dependecies
- [x] Tests
- [ ] Fix compatibility with GForth installed via snap (cwd / project paths)
- [ ] And more..
