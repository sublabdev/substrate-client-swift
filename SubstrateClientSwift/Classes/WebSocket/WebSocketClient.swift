import Foundation

/// Web socket client interface
protocol WebSocketClientProtocol {
    typealias Subscription = (URLSessionWebSocketTask.Message?) -> Void
    typealias ErrorSubscription = (Swift.Error) -> Void
    
    /// Creates a web socket client
    /// - Parameters:
    ///     - host: The host url
    ///     - path: The path
    ///     - port: The port
    ///     - settings: Web socket client settings
    init(host: URL, path: String?, port: Int?, settings: WebSocketClientSettings)
    
    /// Sends a message
    /// - Parameters:
    ///     - message: The message to be sent
    ///     - completion: Completion containing an optional `Error`
    func sendMessage(_ message: URLSessionWebSocketTask.Message, completion: @escaping (Swift.Error?) -> Void)
    
    /// Subscribes to messages
    /// - Parameters:
    ///     - subscribtion: Subscription (completion) wich either contains an `URLSessionWebSocketTask`'s message or nil
    func subscribe(subscription: @escaping Subscription)
    
    /// Subscribes to errors
    /// - Parameters:
    ///     - errorSubscription: Subscription (completion) wich either contains a `Error`'s message or nil
    func subscribeToErrors(_ errorSubscription: @escaping ErrorSubscription)
}

/// Web socket client
final class WebSocketClient: WebSocketClientProtocol {
    private enum Error: Swift.Error {
        case dataEncodingError
        case webSocketTaskError(String)
    }
    
    private let webSocketClientQueue = DispatchQueue(label: "WebSocketClientQueue")
    
    private var subscriptions: [Subscription] = []
    private var errorSubscriptions: [ErrorSubscription] = []
    private var pendingMessages: [URLSessionWebSocketTask.Message] = []
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let settings: WebSocketClientSettings
    private var host: URL
    private var path: String?
    private var port: Int?
    
    private var policy: WebSocketClientSettings.Policy {
        settings.policy
    }
    
    init(host: URL, path: String? = nil, port: Int? = nil, settings: WebSocketClientSettings) {
        self.host = host
        self.path = path
        self.port = port
        self.settings = settings
    }
    
    /// Creates a web socket taks.
    /// > The task is not resumed.
    /// - Returns: An optional `URLSessionWebSocketTask`
    private func createWebSocketTask() -> URLSessionWebSocketTask? {
        if let webSocketTask = webSocketTask {
            return webSocketTask
        }
        
        guard let port = port, let url = URL(string: "\(host):\(port)") else {
            return nil
        }
        
        let urlRequest = URLRequest(url: url)
        let webSocketTask = URLSession(configuration: .default).webSocketTask(with: urlRequest)

        self.webSocketTask = webSocketTask
        return webSocketTask
    }
    
    /// Handles the received `Result` which contains either a message or `Error`
    /// - Parameters:
    ///     - result: Result containing either a message or `Error`
    private func receive(result: Result<URLSessionWebSocketTask.Message, Swift.Error>) {
        switch result {
        case .success(let taskMessage):
            if subscriptions.isEmpty {
                if policy != .none {
                    pendingMessages.append(taskMessage)
                }
            } else {
                subscriptions.forEach {
                    $0(taskMessage)
                }
            }
        case .failure(let error):
            errorSubscriptions.forEach {
                $0(error)
            }
        }
    }
    
    func sendMessage(_ message: URLSessionWebSocketTask.Message, completion: @escaping (Swift.Error?) -> Void) {
        let webSocketTask = createWebSocketTask()
        webSocketTask?.send(message, completionHandler: completion)
        
        webSocketTask?.receive { [weak self] result in
            self?.receive(result: result)
        }
        
        webSocketTask?.resume()
    }
    
    func subscribe(subscription: @escaping Subscription) {
        let isFirst = subscriptions.isEmpty
        subscriptions.append(subscription)
        
        guard !subscriptions.isEmpty else {
            subscription(nil)
            return
        }
        
        func sendMessages() {
            pendingMessages.forEach { subscription($0) }
        }
        
        switch policy {
        case .firstSubscriber:
            if isFirst {
                sendMessages()
                pendingMessages.removeAll()
            }
        case .allSubscribers:
            sendMessages()
        default:
            break
        }
    }

    func subscribeToErrors(_ errorSubscription: @escaping ErrorSubscription) {
        guard policy != .none else { return }
        
        errorSubscriptions.append(errorSubscription)
    }
}
