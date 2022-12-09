import Foundation

/// Web socket client building interface
protocol WebSocketClientBuilder {
    /// Creates a web socket client
    /// - Returns: An object conforming to `WebSocketClientProtocol`
    func webSocketClient() -> WebSocketClientProtocol
}

/// Web socket client factory
struct WebSocketClientFactory: WebSocketClientBuilder {
    private let host: URL
    private var path: String?
    private var port: Int?
    private let settings: WebSocketClientSettings

    /// Creates a web socket client factory
    /// - Parameters:
    ///     - host: The host url
    ///     - path: The path
    ///     - port: The port
    ///     - settings: Web socket client settings
    init(host: URL, path: String? = nil, port: Int? = nil, settings: WebSocketClientSettings) {
        self.host = host
        self.path = path
        self.port = port
        self.settings = settings
    }

    func webSocketClient() -> WebSocketClientProtocol {
        WebSocketClient(host: host, path: path, port: port, settings: settings)
    }
}
