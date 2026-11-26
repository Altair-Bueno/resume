# TODO

## CI

- [ ] **Use a smaller TeX Live image.** `texlive/texlive:latest` is several GB
      and is pulled on every run. Options:
  - `latest-small` plus `tlmgr install`
  - a small pinned image published to GHCR
