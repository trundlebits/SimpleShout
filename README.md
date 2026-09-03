# SimpleShout

_SimpleShout_ is a command-line Icecast source client written in Swift. It
reads Icecast server parameters from a TOML config file and streams a single
local MP3 file to that server.

This project is meant as the most minimal demo of the _SwiftShout_ framework, no new feature requests will be accepted.  This project will always try to align with the application binary interface (ABI) of _SwiftShout_.

## Requirements

- Swift 6.x toolchain.  This project has been tested with Swift 6.x on both macOS and Linux.
- [SwiftShout](https://github.com/trundlebits/SwiftShout) framwework.  This framework will automatically be installed by Swift Package Manager (SPM) when you build and run _SimpleShout_.

## Building

```bash
swift build
```

## Configuring

Copy [the example config](/config.example.toml) and fill in your Icecast server details:

```bash
cp config.example.toml config.toml
```

```toml
host = "icecast.example.com"
port = 8000        # optional, defaults to 8000
user = "source"    # optional, defaults to "source"
password = "hackme"
mount = "/stream.mp3"
```

`config.toml` is gitignored, so real credentials never get committed.

## Usage

```bash
swift run simpleshout --config config.toml <file>.mp3
```

This connects to the Icecast server described in `config.toml` and streams
`<file>.mp3` to the configured mount point.

## Release build

```bash
swift build -c release
```

## Architecture

- `Package.swift` — SwiftPM manifest. Product `simpleshout` is built from
  executable
  target `SimpleShout`, depending on
  [swift-argument-parser](https://github.com/apple/swift-argument-parser),
  [SwiftShout](https://github.com/) (a local path dependency at
  `../SwiftShout.git`), and [TOMLKit](https://github.com/LebJe/TOMLKit).
- `Sources/SimpleShout/SimpleShout.swift` — the CLI entry point. Parses
  `--config <path>` and a positional MP3 file path, wires `IcecastConfig` into
  a `ShoutConnection`, and streams the file.
- `Sources/SimpleShout/IcecastConfig.swift` — `Codable` struct for the TOML
  config file (host/port/user/password/mount, with defaults for port/user).
- `Sources/SimpleShout/MP3FileStreamer.swift` — reads an MP3 file in chunks
  and sends it over an already-open `ShoutConnection`, pacing playback with
  `sync()`.
- `config.example.toml` — template for the config file consumed by `--config`.

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
