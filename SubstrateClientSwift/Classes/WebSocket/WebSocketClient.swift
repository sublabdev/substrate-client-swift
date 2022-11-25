import Foundation

protocol WebSocketClientProtocol {
    init(host: URL, path: String?, port: Int?, settings: WebSocketClientSettings)
    func sendMessage(_ message: URLSessionWebSocketTask.Message, completion: @escaping (Swift.Error?) -> Void)
    func subscribe(_ subscription: @escaping (URLSessionWebSocketTask.Message) -> Void)
    func subscribeToErrors(_ errorSubscription: @escaping (Swift.Error) -> Void)
}

final class WebSocketClient: WebSocketClientProtocol {
    private enum Error: Swift.Error {
        case dataEncodingError
        case webSocketTaskError(String)
    }
    
    typealias Subscription = (URLSessionWebSocketTask.Message) -> Void
    typealias ErrorSubscription = (Swift.Error) -> Void
    
    private let threadMessageSafeQueue = DispatchQueue(label: "WebSocketMessageQueue")
    private let threadErrorSafeQueue = DispatchQueue(label: "WebSocketErrorQueue")
    
    private var subscriptions: [Subscription] = []
    private var _errorSubscriptions: [ErrorSubscription] = []
    private var _pendingMessages: [URLSessionWebSocketTask.Message] = []
    
    private var errorSubscriptions: [ErrorSubscription] {
        get {
            return threadErrorSafeQueue.sync {
                _errorSubscriptions
            }
        } set {
            return threadErrorSafeQueue.async(flags: .barrier) { [unowned self] in
                self._errorSubscriptions = newValue
            }
        }
    }
    
    private var pendingMessages: [URLSessionWebSocketTask.Message] {
        get {
            return threadMessageSafeQueue.sync {
                _pendingMessages
            }
        } set {
            threadMessageSafeQueue.async(flags: .barrier) { [unowned self] in
                self._pendingMessages = newValue
            }
        }
    }
    
    private var pendingErrors: [Swift.Error] = []
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
    
    private func createWebSocketTask() -> URLSessionWebSocketTask? {
        if let webSocketTask = webSocketTask {
            return webSocketTask
        }
        
        guard let port = port, let url = URL(string: "\(host):\(port)") else {
            return nil
        }
        
        let urlRequest = URLRequest(url: url)
        let webSocketTask = URLSession(configuration: .default).webSocketTask(with: urlRequest)
        
        webSocketTask.receive { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let taskMessage):
                self.pendingMessages.append(taskMessage)
                
                if self.policy == .firstSubscriber, let firstSubscriber = self.subscriptions.first {
                    firstSubscriber(taskMessage)
//                    self.subscriptions = [firstSubscriber]
                    self.pendingMessages.removeAll()
                } else if self.policy == .allSubscribers {
                    self.subscriptions.forEach {
                        $0(taskMessage)
                    }
                }
            case .failure(let error):
                self.pendingErrors.append(error)
                
                if self.policy == .firstSubscriber, let firstSubscriber = self.errorSubscriptions.first {
                    firstSubscriber(error)
                    self.subscriptions.removeAll()
                    self.pendingErrors.removeAll()
                } else if self.policy == .allSubscribers {
                    self.errorSubscriptions.forEach { $0(error) }
                }
            }
        }
        
//        self.webSocketTask = webSocketTask
        return webSocketTask
    }
    
    func sendMessage(_ message: URLSessionWebSocketTask.Message, completion: @escaping (Swift.Error?) -> Void) {
        let webSocketTask = createWebSocketTask()
        webSocketTask?.send(message, completionHandler: completion)
        webSocketTask?.resume()
    }
    
    func subscribe(_ subscription: @escaping Subscription) {
        guard policy != .none else {
            return
        }
        
        subscriptions.append(subscription)
        
        if policy == .firstSubscriber, let firstSubscriber = subscriptions.first, !pendingMessages.isEmpty {
            pendingMessages.forEach { firstSubscriber($0) }
            pendingMessages.removeAll()
        } else {
            pendingMessages.forEach { subscription($0) }
        }
    }
    
    func subscribeToErrors(_ errorSubscription: @escaping ErrorSubscription) {
        guard policy != .none else {
            return
        }
        
        errorSubscriptions.append(errorSubscription)
        
        if policy == .firstSubscriber, let firstSubscriber = errorSubscriptions.first, !pendingErrors.isEmpty {
            pendingErrors.forEach { firstSubscriber($0) }
            pendingErrors.removeAll()
        } else {
            pendingErrors.forEach { errorSubscription($0) }
        }
    }
}
