# learnharness-machine

Linux x64 server builds of [LearnHarness](https://github.com/amosblomqvist/learnharness)
(an agent harness for learning, by Amos Blomqvist, AGPL-3.0), packaged to run
as a Quartzi Machine app.

Each release tarball is upstream's own standalone Next.js server, built from
the matching upstream tag **without modification** by `build-learnharness.sh`.
`SOURCE.txt` inside each tarball names the upstream tag and commit; that
commit is the complete corresponding source.

```bash
bash build-learnharness.sh 0.3.5 ./out
```

Run on Linux x86_64 with Node 26 and git. The script prints the sha256 and
size of the tarball. Builds are not byte-reproducible, so a consumer pins the
file published on the release, not a local rebuild.

Licensed AGPL-3.0, the same as upstream (see `LICENSE`).
