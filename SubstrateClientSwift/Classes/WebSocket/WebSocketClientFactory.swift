import Foundation

protocol WebSocketClientBuilder {
    func webSocketClient() -> WebSocketClientProtocol
}

struct WebSocketClientFactory: WebSocketClientBuilder {
    private let host: URL
    private var path: String?
    private var port: Int?
    private let settings: WebSocketClientSettings
    
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
