import Foundation

extension SubstrateWebSocketClient {
    struct Request<T: Codable>: Codable {
        let id: String
        let request: T
    }
}
