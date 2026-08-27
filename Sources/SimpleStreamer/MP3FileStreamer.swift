import Foundation
import SwiftShout

struct StreamerError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

func streamMP3File(at path: String, over connection: ShoutConnection) throws {
    guard let file = FileHandle(forReadingAtPath: path) else {
        throw StreamerError(message: "Couldn't open MP3 file at \(path)")
    }
    defer { try? file.close() }

    let chunkSize = 4096
    while let chunk = try file.read(upToCount: chunkSize), !chunk.isEmpty {
        do {
            try connection.send([UInt8](chunk))
        } catch {
            throw StreamerError(message: "Failed sending audio data: \(error)")
        }
        connection.sync()
    }
}
