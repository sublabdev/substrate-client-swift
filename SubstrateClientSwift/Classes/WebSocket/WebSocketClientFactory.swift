import Foundation

/// Web socket client building interface
protocol WebSocketClientBuilder {
    /// Creates a web socket client
    /// - Returns: An object conforming to `WebSocketClientProtocol`
    func webSocketClient() -> WebSocketClientProtocol
}

/// Web socket client factory
struct WebSocketClientFactory: WebSocketClientBuilder {
    private let secure: Bool
    private let host: String
    private let path: String?
    private let params: [String: String?]
    private let port: Int?
    private let policy: WebSocketClientSubscriptionPolicy

    /// Creates a web socket client factory
    /// - Parameters:
    ///     - host: The host url
    ///     - path: The path
    ///     - port: The port
    ///     - settings: Web socket client settings
    init(
        secure: Bool = false,
        host: String,
        path: String? = nil,
        params: [String: String?] = [:],
        port: Int? = nil,
        policy: WebSocketClientSubscriptionPolicy = .none
    ) {
        self.secure = secure
        self.host = host
        self.path = path
        self.params = params
        self.port = port
        self.policy = policy
    }

    func webSocketClient() -> WebSocketClientProtocol {
        WebSocketClient(
            secure: secure,
            host: host,
            path: path,
            params: params,
            port: port,
            policy: policy
        )
    }
}
