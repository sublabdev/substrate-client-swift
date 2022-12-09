import Foundation

extension SubstrateWebSocketClient {
    /// Generic web socket request wrapper. Consists of id and a generic request itself
    /// which should conform to `Codable`
    struct Request<T: Codable>: Codable {
        let id: String
        let request: T
    }
}
