# fmix 0.10.0 — wordlist dispatch + GForth on GHCR

## Highlights

- **CLI dispatch via wordlist** — commands registered with `synonym` in
  `fmix.commands`; lookup through `search-wordlist` instead of a long
  `compare` IF/ELSE chain. TTY restore before `bye` unchanged.
- **GForth 0.7.9 on GHCR** — `ghcr.io/vitasound/gforth:0.7.9`, install onto
  the host at `/opt/gforth-0.7.9` (no snap):

```bash
bash scripts/install-gforth-from-ghcr.sh
export PATH="/opt/gforth-0.7.9/bin:$PATH"
```

## CI

- Prefers GHCR image (login + copy to `/opt/gforth-0.7.9`); falls back to
  building only the `gforth` target from source.
- Coverage step fetches fcov dependencies (`packages.get`) and keeps
  gforth on `PATH`.
