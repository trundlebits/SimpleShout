// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import SwiftShout

@main
struct simplestreamer: ParsableCommand {
    @Option(help: "Path to a TOML config file with Icecast server parameters.")
    var config: String

    @Argument(help: "Path to the MP3 file to stream.")
    var file: String

    mutating func run() throws {
        let icecastConfig = try IcecastConfig.load(from: config)

        _ = SwiftShout()

        guard let connection = ShoutConnection() else {
            throw StreamerError(message: "shout_new() failed")
        }

        connection.setHost(icecastConfig.host)
        connection.setPort(icecastConfig.port)
        connection.setUser(icecastConfig.user)
        connection.setPassword(icecastConfig.password)
        connection.setMount(icecastConfig.mount)
        connection.setContentFormat(format: .mp3, usage: .audio)

        do {
            try connection.open()
        } catch {
            throw StreamerError(
                message: "Couldn't connect to \(icecastConfig.host):\(icecastConfig.port)\(icecastConfig.mount): \(error)"
            )
        }
        defer { connection.close() }

        try streamMP3File(at: file, over: connection)
    }
}
