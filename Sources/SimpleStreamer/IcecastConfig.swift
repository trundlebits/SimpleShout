import Foundation
import TOMLKit

struct IcecastConfig: Codable {
    let host: String
    let port: UInt16
    let user: String
    let password: String
    let mount: String

    private enum CodingKeys: String, CodingKey {
        case host, port, user, password, mount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        host = try container.decode(String.self, forKey: .host)
        password = try container.decode(String.self, forKey: .password)
        mount = try container.decode(String.self, forKey: .mount)
        port = try container.decodeIfPresent(UInt16.self, forKey: .port) ?? 8000
        user = try container.decodeIfPresent(String.self, forKey: .user) ?? "source"
    }

    static func load(from path: String) throws -> IcecastConfig {
        let contents: String
        do {
            contents = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
        } catch {
            throw ShoutError(message: "Couldn't read config file at \(path): \(error.localizedDescription)")
        }

        do {
            let table = try TOMLTable(string: contents)
            return try TOMLDecoder().decode(IcecastConfig.self, from: table)
        } catch {
            throw ShoutError(message: "Couldn't parse TOML config at \(path): \(error)")
        }
    }
}
