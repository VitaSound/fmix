# fmix
[![License](https://img.shields.io/badge/License-COPL-red.svg)](https://raw.githubusercontent.com/VitaSound/fmix/refs/heads/master/LICENSE)
[![Ver](https://img.shields.io/badge/Ver-0.4.0-green.svg)](https://github.com/VitaSound/fmix/releases/tag/0.4.0)

FMix is a build tool that provides tasks for creating, and testing Forth packages, managing its dependencies, and more.

```bash
$ fmix

FMix v0.4.0 is a build tool that provides tasks for creating, and testing Forth packages, managing its dependencies.
Usage: fmix <command> [args]
Commands:
   new <name>       - Create new package
   packages.get     - Install dependencies
   test [test_file] - Run project tests or test
   version          - Show version
```

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
    alias fmix='gforth "$FMIX_HOME/fmix.4th" -e'
```

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

# Status

- [x] Create package
- [x] Get dependecies
- [x] Tests
- [ ] Fix compatibility with GForth installed via snap (cwd / project paths)
- [ ] And more..
