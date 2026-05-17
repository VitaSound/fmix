## FMix 0.4.3

### Fixed
- Restore the shell TTY after exit so prompts do not show terminal garbage such as `[?2004l` or `0c0c` (common on WSL and Windows).

### Changed
- Document a `fmix()` shell function with `stty sane` instead of a plain `alias` in README.
- Call `fmix.exit` (with TTY restore) on error paths in utilities and tests.
