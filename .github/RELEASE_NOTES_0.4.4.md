## FMix 0.4.4

### Fixed
- Restore TTY after every command to prevent `0c0c` / `[?2004l` garbage on WSL prompts: single exit via `0 bye`, `bin/fmix` wrapper, `FMIX_CMD` env vars, and a short `/dev/tty` input-drain for queued terminal replies.
- Fix `fmix.restore-terminal` stack underflow: do not `drop` after `system` in GForth 0.7.9.
- Refactor command dispatch without `EXIT` so TTY restore always runs before exit.
- Fix `fmix` with no arguments: `bin/fmix` defaults to `help` instead of stack underflow after `-e`.
- Fix optional parameter in `fmix.read_args` when the command has no extra argument.
- Fix terminal garbage after `fmix new` and other commands: use `bin/fmix` launcher, restore TTY in shell and after `fmix.new`.
- Restore TTY after `fmix test`, `packages.get`, `version`, and `help`; reset bracketed-paste in `bin/fmix` before and after GForth.
- Use `fmix.exit` when `package.4th` is missing in `packages.get` (plain `EXIT` skipped TTY restore).
