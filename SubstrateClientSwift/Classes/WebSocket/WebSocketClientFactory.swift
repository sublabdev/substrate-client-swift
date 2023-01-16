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

/// Web socket client building interface
protocol WebSocketClientBuilder {
    /// Creates a web socket client
    /// - Returns: An object conforming to `WebSocketClientProtocol`
    func webSocketClient() -> WebSocketClientProtocol
}

// MARK: - Implementation

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

    /// Creates a web socket client
    ///  -Returns: A web socket client
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
