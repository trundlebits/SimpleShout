# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

SimpleStreamer is a Swift package scaffolded via `swift package init --type tool`. Its purpose is a
file/playlist Icecast source client. The first real feature is in place: `simplestreamer` reads
Icecast server parameters (host/port/user/password/mount) from a TOML config file and streams a
single local MP3 file to that server over `SwiftShout`. Playlist looping, multiple files, in-stream
metadata, and signal handling are not implemented yet.

SwiftShout's libshout actions (`open()`, `send(_:)`) are `throws(ShoutError)` typed throws, not
status-code returns. SimpleStreamer's own error type is `StreamerError` (renamed from `ShoutError`
to avoid colliding with the now-public `SwiftShout.ShoutError`); call sites catch `ShoutError` and
re-wrap it as `StreamerError` for CLI output.

## Tech Stack

- Swift 6.x for the primary programming language
- BASH shell scripts as needed for helpers of the main application.

## Architecture

- `Package.swift` — SwiftPM manifest. Swift tools version 6.3, Swift language mode v6, macOS 15+.
  Product `simplestreamer` is built from executable target `SimpleStreamer`, which depends on
  [swift-argument-parser](https://github.com/apple/swift-argument-parser), on `SwiftShout`
  (a local path dependency at `../SwiftShout.git`, a sibling checkout), and on
  [TOMLKit](https://github.com/LebJe/TOMLKit) for config file parsing.
- `Sources/SimpleStreamer/simplestreamer.swift` — the executable target's entry point (directory
  matches the target name in the manifest; the product name `simplestreamer` is the CLI
  binary/command name). Not named `main.swift`: a file literally named `main.swift` is always parsed
  with top-level-code semantics, which conflicts with `@main` once a target has more than one source
  file. Parses `--config <path>` and a positional MP3 file path, then wires `IcecastConfig` into a
  `ShoutConnection` and streams the file. (The `@main` type inside is still named `kaos`, a leftover
  from the KAOS_Streamer copy, so the CLI usage string reads `kaos`.)
- `Sources/SimpleStreamer/IcecastConfig.swift` — `Codable` struct for the TOML config file
  (host/port/user/password/mount, with defaults for port/user), plus `IcecastConfig.load(from:)`.
- `Sources/SimpleStreamer/MP3FileStreamer.swift` — `streamMP3File(at:over:)`, which reads an MP3 file
  in chunks and sends it over an already-open `ShoutConnection`, pacing with `sync()`. Also defines
  `StreamerError`, the package's local `LocalizedError`.
- `config.example.toml` — template for the config file consumed by `--config`.
- `Tests/SimpleStreamerTests/SimpleStreamerTests.swift` — test target `SimpleStreamerTests`, using the new
  [swift-testing](https://swiftpackageindex.com/swiftlang/swift-testing/documentation) framework
  (`import Testing`, `@Test` macro, `#expect(...)`), not XCTest.

## Commands

- Build: `swift build`
- Run the CLI: `swift run simplestreamer --config config.toml <file>.mp3` (copy `config.example.toml`
  to `config.toml` and fill in real Icecast credentials first; `config.toml` is gitignored)
- Run all tests: `swift test`
- Run a single test: `swift test --filter <TestName>` (e.g. `swift test --filter example`)
- Release build: `swift build -c release`
