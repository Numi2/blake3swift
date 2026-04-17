# Release Process

BLAKE3Swift is proprietary source-available software. Public source visibility supports evaluation, audit, and benchmark review; it does not grant production or commercial rights.

## Versioning

Use semantic version tags:

- `v0.MINOR.PATCH` before API stability.
- `v1.0.0` for the first source-stable public API.
- Increment `PATCH` for compatible fixes.
- Increment `MINOR` for compatible features or benchmark tooling.
- Increment `MAJOR` for source-breaking API changes after `1.0.0`.

Pre-release tags use semver suffixes such as `v0.4.0-alpha.1` or `v1.0.0-rc.1`.

## Tag Rules

Every release tag must point to a commit with:

- `LICENSE.md` present and unchanged unless the release notes call out a license update.
- `CHANGELOG.md` updated.
- README installation instructions pointing at a tag, not only a branch.
- API stability status documented in `docs/api-stability.md`.
- Benchmark methodology documented beside any performance numbers.
- Correctness tests run for official vectors, streaming, keyed hash, XOF, file hashing, and Metal-vs-CPU parity where Metal is available.

## Release Gates

For a public release, collect and attach:

- `swift --version`
- `sw_vers`
- `sysctl -n machdep.cpu.brand_string` or Apple silicon model identifier
- `git rev-parse HEAD`
- Benchmark commands, raw Markdown output, and JSON reports
- Autotune command, raw Markdown output, JSON report, and accepted constants when changing Metal thresholds or modes
- Metal library source mode: runtime source compiler or packaged `.metallib`
- Thermal window and power mode notes

For performance claims, keep these timing classes separate:

- CPU scalar
- CPU serial SIMD
- CPU parallel
- Metal resident
- Metal staged/private/wrapped diagnostics
- Metal end-to-end
- CPU file
- Metal file
- Sustained resident or staged long run

## GitHub Release Notes

Use the template in `CHANGELOG.md`. Each release should include:

- Commercial license reminder.
- API stability status.
- Correctness coverage.
- Performance methodology.
- Raw benchmark artifacts.
- Known limitations.

Do not promote single best samples as sustained throughput. Sustained claims require repeated large-input runs with median, min, max, p95, first-quarter, last-quarter, and correctness.
