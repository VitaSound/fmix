---
title: "FMix: a tiny Mix for Forth"
published: false
tags: forth, opensource, tooling, devtools
---

# FMix: a tiny Mix for Forth

In modern programming languages, we almost always expect the language to come with a convenient tool for working with projects.

Elixir has [Mix](https://hexdocs.pm/mix/Mix.html). Rust has [Cargo](https://doc.rust-lang.org/cargo/). Ruby has [Bundler](https://bundler.io/) and [RubyGems](https://rubygems.org/). Haskell has [Cabal](https://www.haskell.org/cabal/) and [Stack](https://docs.haskellstack.org/). JavaScript has [npm](https://www.npmjs.com/), [pnpm](https://pnpm.io/) and [Yarn](https://yarnpkg.com/). Go has [modules](https://go.dev/ref/mod).

We are used to being able to create a project with one command, describe dependencies in one file, fetch them from the network, run tests, and prepare a release. It feels like a basic part of the ecosystem, not a luxury.

But older programming languages often have a different story.

When many of them were created, this approach was not yet a standard expectation. Code was distributed differently, projects were structured differently, and ecosystems grew without the package managers and build tools we now take for granted.

And you can still feel it today.

## Why I Started Thinking About This

For one of my projects I use [Forth](https://forth-standard.org/).

Forth is a very interesting language. It is minimalistic, direct, and unusual. There is something very attractive about it: you are close to computation, close to the stack, and close to the actual hardware of the computer, which I sometimes build myself.

But when I started writing something in Forth that looked more or less like a project, I quickly began missing the usual things:

- creating a new project;
- describing dependencies;
- downloading dependencies;
- running tests;
- having a clear project structure;
- connecting libraries from Git;
- not having to keep everything manually in my head.

Yes, you can use git submodules, copy files by hand, or invent your own conventions. But for me, this is not a very convenient path. I wanted something closer to what I am used to in modern languages.

I found the `f.4th` system, which is connected to [theforth.net](https://theforth.net/). It is a useful tool, but it follows a different approach: library code and versions are stored on its own server.

I wanted to be able to pull dependencies directly from Git repositories. For example, specify a GitHub URL, a branch or a tag, and get the library into the project.

That is how the idea for `fmix` appeared.

## What Is FMix

`fmix` is a small build tool and package tool for Forth, inspired by Elixir Mix.

Repository: [github.com/VitaSound/fmix](https://github.com/VitaSound/fmix)

It does not try to be a large framework. Its goal is simpler: to give a Forth project a minimal set of familiar tools.

Right now `fmix` can do this:

```bash
fmix new example
fmix packages.get
fmix test
fmix version
```

In other words, you can create a new package, fetch dependencies, run tests, and check the tool version.

## Creating a Project

A new project is created like this:

```bash
fmix new example
cd example
```

After that, you get a basic project structure:

```text
example/
  example.4th
  package.4th
  README.md
  tests/
  forth-packages/
```

`package.4th` is the package description file. It contains the name, version, license, main file, and dependencies.

Example:

```forth
forth-package
    key-value name example
    key-value version 0.1.0
    key-value license COPL
    key-value description example
    key-value main example.4th

    key-list dependencies f git https://github.com/VitaSound/f tag 0.2.4
    key-list dependencies ttester git https://github.com/VitaSound/ttester tag 1.1.0
end-forth-package
```

I like that the file itself is also written in a Forth-like style. It is not JSON, YAML, or TOML. It is a tiny declarative Forth format.

## Dependencies from Git

The main reason I started making `fmix` was Git dependencies.

In `package.4th`, you can define a dependency like this:

```forth
key-list dependencies ftest git https://github.com/VitaSound/ftest.git branch main
```

Or like this, if you need a specific version via a tag:

```forth
key-list dependencies ftest git https://github.com/VitaSound/ftest.git tag 0.1.0
```

After that, you only need to run:

```bash
fmix packages.get
```

Dependencies will be installed into the local project directory:

```text
./forth-packages/
```

This structure makes it possible to keep different versions of the same library side by side:

```text
forth-packages/
  f/
    0.2.4/
  ttester/
    1.1.0/
```

You can include a dependency with the usual `require`:

```forth
require ./forth-packages/f/0.2.4/f.4th
```

## Support for theforth.net

Although I wanted Git dependencies, I did not want to completely abandon the existing ecosystem.

So `fmix` can also work with packages from `theforth.net` through `f.4th`.

For example:

```forth
key-list dependencies f 0.2.4
```

This means one project can use both Git dependencies and packages from `theforth.net`.

## Tests

Another basic thing I was missing was running tests.

`fmix` has this command:

```bash
fmix test
```

It runs tests from the `tests/` directory.

You can also run a specific file:

```bash
fmix test tests/some_test.4th
```

Tests use `ttester`. If `ttester` exists in the project dependencies, `fmix` loads it from `./forth-packages`. If not, it uses the version from the installed `FMIX_HOME`.

For me, this matters: tests should run with one command. Even if the project is small.

## What Was Fixed in Recent Versions

`fmix` has already gone through several generations of changes.

I wrote the first versions myself. But I am not a very strong Forth developer, so many things were difficult for me. I made one major refactoring with the help of Gemini. I finished the latest version with Cursor.

The latest releases fixed quite a few practical problems.

GitHub Actions CI was added: the workflow builds [GForth](https://www.gnu.org/software/gforth/) 0.7.9 from source and runs:

```bash
gforth fmix.4th -e version
gforth fmix.4th -e test
```

Later, a release pipeline was added: when a version tag is pushed, a GitHub Release is created automatically, and the release text is taken from `.github/RELEASE_NOTES_X.Y.Z.md`.

Path handling was also fixed. Previously, part of the logic depended on `PWD`. Now the project is detected from the directory where the command is started. This matters because `FMIX_HOME` points to the installed `fmix`, while commands should operate on the current project.

Several dependency installation problems were fixed:

- `git clone` now checks its result;
- failed shell commands make GForth exit with code `1`;
- parent directories are created before `git clone`;
- `git fetch` and `checkout` are executed so that failures are not hidden;
- Git commands use `GIT_TERMINAL_PROMPT=0`, so the command does not hang in a non-interactive environment.

Another important thing is input validation. `fmix` validates package names, versions, paths, Git URLs, and Git refs before calling `cp`, `sed`, or `git`. It is not a complex escaping system, but a simple whitelist. It rejects spaces, `;`, `$`, backticks, pipes, and other shell metacharacters.

## An Unexpected Terminal Problem

There was a separate story with the terminal. Before using the `fmix` command in the console, it had to be configured as an alias.

When running through a simple alias like this:

```bash
alias fmix='gforth "$FMIX_HOME/fmix.4th" -e'
```

the terminal sometimes ended up in a bad state after commands finished. Strange symbols appeared in the prompt, for example:

```text
0c0c
[?2004l
```

This was especially visible in WSL.

In version `0.4.4`, I switched to the `bin/fmix` launcher script. It restores the TTY after commands, resets bracketed paste mode, and briefly drains queued input from `/dev/tty`. To be honest, I would definitely not have solved all of that on my own. I patiently helped the neural network try hypothesis after hypothesis to fix the problem. Unlike the AI tools I had tried before, this time I only had to stop the AI once and create a new context because it seemed to get stuck in an endless correction loop.

But it worked, and now instead of an alias it is recommended to use:

```bash
export FMIX_HOME="$HOME/fmix"
export PATH="$FMIX_HOME/bin:$PATH"
```

And then run it simply as:

```bash
fmix
```

## Installation

Right now installation looks like this:

```bash
git clone https://github.com/VitaSound/fmix.git ~/fmix
```

Then add this to your shell config, for example `.bashrc`:

```bash
export FMIX_HOME="$HOME/fmix"
export PATH="$FMIX_HOME/bin:$PATH"
```

After that, the command should work directly in the console:

```bash
fmix version
```

Important: at the moment `fmix` expects Linux, Git, sed, cp, and [GForth](https://www.gnu.org/software/gforth/) 0.7.9.

I do not recommend using earlier versions of GForth or the [Snap](https://snapcraft.io/) version. Snap runs programs in a confined environment, so the current directory and paths may not match what the shell session expects. This breaks commands like `new` and `packages.get`.

It is better to use GForth from apt, a local build, or a tarball from the [official GForth page](https://www.gnu.org/software/gforth/).

## Why This Matters

I think old languages really need tools like this.

They do not have to be huge. They do not have to be perfect. But they should at least cover the basic scenarios. When a language has a convenient tool around projects, it becomes friendlier.

It is easier for a new person to try the language. It is easier for an existing user to start a new project. Libraries are easier to reuse. Tests are easier to run. CI is easier to configure.

This does not change the language itself, but it changes the experience of working with it.

In the case of Forth, this is especially interesting. Forth is often seen as something old, strange, and niche. But maybe part of that "oldness" is not only in the language itself, but also in the absence of familiar modern tooling around it.

If we add convenient tools, the language can feel very different.

## What Is Next

`fmix` is still small and experimental.

Right now it can create packages, fetch dependencies from Git and `theforth.net`, run tests, and publish releases through GitHub Actions.

In the future, I would like to improve compatibility, add documentation, and maybe add more commands around Forth package development.

But even now, it has become much more convenient for me to work on my Forth projects. But that is another story.

## Links

- [FMix on GitHub](https://github.com/VitaSound/fmix)
- [GForth](https://www.gnu.org/software/gforth/)
- [theforth.net](https://theforth.net/)
- [STM8 eForth](https://github.com/TG9541/stm8ef)
- [[NF] Forth-like languages, язык Форт](https://t.me/forthchat)
- [[TF] Форт и общение фортеров](https://t.me/ruforth)

