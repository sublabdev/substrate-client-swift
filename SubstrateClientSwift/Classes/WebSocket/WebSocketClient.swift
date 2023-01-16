/**
 *
 * Copyright 2023 SUBSTRATE LABORATORY LLC <info@sublab.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

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
    init(
        secure: Bool,
        host: String,
        path: String?,
        params: [String: String?],
        port: Int?,
        policy: WebSocketClientSubscriptionPolicy
    )
    
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
    
    private let secure: Bool
    private let host: String
    private let path: String?
    private let params: [String: String?]
    private let port: Int?
    private let policy: WebSocketClientSubscriptionPolicy
    
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
    
    /// Creates a web socket taks.
    /// > The task is not resumed.
    /// - Returns: An optional `URLSessionWebSocketTask`
    private func createWebSocketTask() -> URLSessionWebSocketTask? {
        if let webSocketTask = webSocketTask {
            return webSocketTask
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = secure ? "wss" : "ws"
        urlComponents.host = host
        urlComponents.path = "/\(path ?? "")"
        urlComponents.port = port
        urlComponents.queryItems = params.map { .init(name: $0, value: $1) }
        guard let url = urlComponents.url else {
            assertionFailure()
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
    
    /// Sends the provided message
    /// - Parameters:
    ///     - message: Message to send
    ///     - completion: Completion with optional error
    func sendMessage(_ message: URLSessionWebSocketTask.Message, completion: @escaping (Swift.Error?) -> Void) {
        let webSocketTask = createWebSocketTask()
        webSocketTask?.send(message, completionHandler: completion)
        
        webSocketTask?.receive { [weak self] result in
            self?.receive(result: result)
        }
        
        webSocketTask?.resume()
    }
    
    /// Subscribes for updates upon recieving messages
    /// - Parameters:
    ///     - subscription: Subscription that wants to subscribe
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

    /// Subscribes to errors u
    func subscribeToErrors(_ errorSubscription: @escaping ErrorSubscription) {
        guard policy != .none else { return }
        
        errorSubscriptions.append(errorSubscription)
    }
}
