import CShout
import Foundation
import SwiftShout

struct ShoutError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

func streamMP3File(at path: String, over connection: ShoutConnection) throws {
    guard let file = FileHandle(forReadingAtPath: path) else {
        throw ShoutError(message: "Couldn't open MP3 file at \(path)")
    }
    defer { try? file.close() }

    let chunkSize = 4096
    while let chunk = try file.read(upToCount: chunkSize), !chunk.isEmpty {
        guard connection.send([UInt8](chunk)) == SHOUTERR_SUCCESS else {
            throw ShoutError(message: "Failed sending audio data: \(connection.errorDescription)")
        }
        connection.sync()
    }
}
