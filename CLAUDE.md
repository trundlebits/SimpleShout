# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Source of truth

Both projects are public and canonically hosted under the
[trundlebits](https://github.com/trundlebits) GitHub organization:

- **SimpleShout** (this repo): <https://github.com/trundlebits/SimpleShout>
- **SwiftShout** (the framework this depends on): <https://github.com/trundlebits/SwiftShout>

Treat those GitHub repositories as the source of truth for both projects.

## Shared Claude Code artifact page

All three related projects — **KAOS_Streamer**, **SwiftShout**, and **SimpleShout** —
document their architecture on one shared Claude Code artifact,
"KAOS_Streamer × SwiftShout":
<https://claude.ai/code/artifact/e7f190b0-3164-4470-b3e0-6044c7930d66>

SimpleShout has no artifact of its own; its notes are the section
"A second consumer: SimpleShout" on that page. Because any of the three projects
may republish the page, a locally cached copy can go stale — re-read the live
artifact before editing it, and update that section whenever SimpleShout's shape
changes.

## Project state

SimpleShout is a Swift package scaffolded via `swift package init --type tool`. Its purpose is a
file/playlist Icecast source client. The first real feature is in place: `simpleshout` reads
Icecast server parameters (host/port/user/password/mount) from a TOML config file and streams a
single local MP3 file to that server over `SwiftShout`. Playlist looping, multiple files, in-stream
metadata, and signal handling are not implemented yet.

SwiftShout's libshout actions (`open()`, `send(_:)`) are `throws(ShoutError)` typed throws, not
status-code returns. SimpleShout's own error type is `SimpleShoutError` (named to avoid colliding
with the public `SwiftShout.ShoutError`); call sites catch `ShoutError` and re-wrap it as
`SimpleShoutError` for CLI output.

## Tech Stack

- Swift 6.x for the primary programming language
- BASH shell scripts as needed for helpers of the main application.

## Architecture

- `Package.swift` — SwiftPM manifest. Swift tools version 6.3, Swift language mode v6, macOS 15+.
  Product `simpleshout` is built from executable target `SimpleShout`, which depends on
  [swift-argument-parser](https://github.com/apple/swift-argument-parser), on
  [SwiftShout](https://github.com/trundlebits/SwiftShout) (a remote source-control
  dependency fetched from GitHub, currently tracking the `main` branch since
  SwiftShout has not yet tagged a release), and on
  [TOMLKit](https://github.com/LebJe/TOMLKit) for config file parsing.
- `Sources/SimpleShout/SimpleShout.swift` — the executable target's entry point (directory
  matches the target name in the manifest; the product name `simpleshout` is the CLI
  binary/command name). Not named `main.swift`: a file literally named `main.swift` is always parsed
  with top-level-code semantics, which conflicts with `@main` once a target has more than one source
  file. Parses `--config <path>` and a positional MP3 file path, then wires `IcecastConfig` into a
  `ShoutConnection` and streams the file. The `@main` type is `struct SimpleShout`; the compiled
  binary name comes from `.executable(name:)` in `Package.swift`, not the type name, and its
  `CommandConfiguration(commandName:)` keeps the help/usage text showing `simpleshout` rather than
  the argument-parser default of `simple-shout`.
- `Sources/SimpleShout/IcecastConfig.swift` — `Codable` struct for the TOML config file
  (host/port/user/password/mount, with defaults for port/user), plus `IcecastConfig.load(from:)`.
- `Sources/SimpleShout/MP3FileStreamer.swift` — `streamMP3File(at:over:)`, which reads an MP3 file
  in chunks and sends it over an already-open `ShoutConnection`, pacing with `sync()`. Also defines
  `SimpleShoutError`, the package's local `LocalizedError`.
- `config.example.toml` — template for the config file consumed by `--config`.

This project has no test target.

## Commands

- Build: `swift build`
- Run the CLI: `swift run simpleshout --config config.toml <file>.mp3` (copy `config.example.toml`
  to `config.toml` and fill in real Icecast credentials first; `config.toml` is gitignored)
- Release build: `swift build -c release`
