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

// MARK: - Protocol

/// An interface for substrate web socket client
public protocol WebSocket: AnyObject {
    /// Sends a generic request
    /// - Parameters:
    ///     - request: Generic request conforming to `Codable`
    ///     - completion: Completion containing an optional `Error`
    func sendRequest<T: Codable>(_ request: T, completion: @escaping (Error?) -> Void) throws
    
    /// Subscribes to client's messages
    /// - Parameters:
    ///     - completion: Completion with either `URLSessionWebSocketTask.Message` or nil
    func subscribe(completion: @escaping (URLSessionWebSocketTask.Message?) -> Void)
    
    /// Subscribes to client's errors
    /// - Parameters:
    ///     - errorSubscription: Completion with `Error.Message`
    func subscribeToErrors(_ errorSubscription: @escaping (Error) -> Void)
}

// MARK: - Implementation

public final class SubstrateWebSocketClient: WebSocket {
    private let client: WebSocketClientProtocol

    /// Creates a substrate web socket client
    init(wsClientBuilder: WebSocketClientBuilder) {
        client = wsClientBuilder.webSocketClient()
    }
    
    public func sendRequest<T: Codable>(_ request: T, completion: @escaping (Error?) -> Void) throws {
        let webSocketRequest = Request(id: UUID().uuidString, request: request)
        try sendRequest(webSocketRequest, completion: completion)
    }
    
    public func subscribe(completion: @escaping (URLSessionWebSocketTask.Message?) -> Void) {
        client.subscribe(subscription: completion)
    }
    
    public func subscribeToErrors(_ errorSubscription: @escaping (Error) -> Void) {
        client.subscribeToErrors(errorSubscription)
    }
    
    /// Sends an encoded request as a message of type `.data`
    /// - Parameters:
    ///     - request: Generic request conforming to `Codable`
    ///     - completion: Completion containing an optional `Error`
    private func sendRequest<T: Codable>(
        _ request: Request<T>,
        completion: @escaping (Error?) -> Void
    ) throws {
        let encodedRequest = try JSONEncoder().encode(request)
        client.sendMessage(.data(encodedRequest), completion: completion)
    }
}
