# Contributing to Mokr

Thank you for your interest in mokr. This document explains how contributions work,
what is accepted, and the terms under which contributions are made.

## Maintainer

mokr is currently maintained by **MNBLabs** ([@MNBLabs](https://github.com/MNBLabs)),
with contributions by **Nishan Bhuinya** ([@nishanbhuinya](https://github.com/nishanbhuinya)).
All contributions are reviewed and merged at the maintainer's sole discretion.
There is no obligation to merge any contribution, regardless of quality.

> The project may be transferred to a new organisation in the future.
> This document will be updated to reflect any such change.

## Design Principles (Read Before Contributing)

Every contribution must respect mokr's core principles:

**Mokr adapts to the developer's widgets. Developers do not adapt to Mokr.**

What this means in practice:

- **Moldability over prescription.** New features should hand developers standard Flutter
  primitives (`ImageProvider`, `String`, `double`) — not new Mokr widgets they are
  expected to adopt.
- **Determinism is the law.** Same seed → same output, always, everywhere, forever.
  No contribution may introduce `DateTime.now()`, `String.hashCode`, or any
  non-deterministic value into a generator.
- **Minimal dependency surface.** mokr's only allowed dependencies are the `flutter` SDK
  and `path_provider`. No new dependencies will be accepted.
- **Sync API by default.** The only public async methods are `init()` and the
  `slots.*` / `cache.*` management calls. No contribution may make a currently
  synchronous method asynchronous.
- **Debug-only, always.** mokr must never run in release builds. No contribution may
  weaken or remove this guarantee.

## What Is Welcome

- Bug fixes with a clear reproduction case
- New `MokrCategory` values (append-only — existing values must not change or move)
- New `Mokr.text.*` methods that generate useful string content
- Additional data table entries (names, bio phrases, captions) that improve diversity
- Performance improvements that do not change any public API or output
- Documentation improvements and typo fixes

## What Will Not Be Accepted

- Any change to `SeedHash.hash()` output — this is a semver stability contract
- Any change to RNG consumption order in `UserGenerator` or `PostGenerator`
- Adding dependencies beyond `flutter` SDK and `path_provider`
- Re-introducing `pin`, `shared_preferences`, or any removed concept
- New prebuilt widgets that developers are expected to use as primary API
- Changes that make any currently synchronous public method asynchronous
- Anything that could cause mokr to run in release builds

## How to Contribute

1. **Open an issue first.** Describe what you want to change and why. Wait for a
   response before writing code. This avoids wasted effort on contributions that
   won't be merged.

2. **Fork the repository.** Work on a branch named `fix/description` or
   `feature/description`.

3. **Follow the code standards:**
   - `flutter analyze --fatal-infos` must pass with zero issues
   - `dart format` must produce no changes
   - All existing tests must continue to pass
   - New behaviour must have tests
   - All public symbols must have dartdoc with at least one code example

4. **Open a pull request** against the `main` branch. Reference the issue number.
   Include a clear description of what changed and why.

## Contributor License Agreement

By submitting a pull request or any other contribution to this repository, you agree
to the following terms:

1. **License grant.** You grant MNBLabs and Nishan Bhuinya a perpetual, worldwide,
   non-exclusive, royalty-free, irrevocable license to use, reproduce, modify,
   distribute, and sublicense your contribution as part of mokr, under the project's
   MIT License or any future license the maintainer chooses to apply.

2. **Original work.** You represent that your contribution is your original work and
   that you have the right to grant the above license. You represent that your
   contribution does not include any third-party material that would conflict with
   this grant.

3. **No warranty.** Your contribution is provided as-is, without warranty of any kind.
   The maintainer is not liable for any issues arising from the inclusion of your
   contribution.

4. **No claim of ownership.** Contributing to mokr does not grant you any ownership
   over the project, its name, its trademarks, or any future commercial use.

These terms are consistent with the
[Developer Certificate of Origin (DCO)](https://developercertificate.org/).

## Forking

mokr is MIT licensed. You are free to fork it and use it under the terms of the
[LICENSE](LICENSE) file. If you publish a fork to pub.dev, choose a different package
name. Do not publish a fork as `mokr`.

## Code of Conduct

Be direct and respectful. Contributions are evaluated on technical merit against the
design principles above. Discussions should stay focused on the code and the problem,
not on the people involved.

## Questions

Open a [GitHub Discussion](https://github.com/MNBLabs/mokr/discussions) for questions
that are not bug reports or contribution proposals.
