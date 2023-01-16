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

/// Substrate client settings
public struct SubstrateClientSettings {
    public var rpcPath: String?
    public var rpcParams: [String: String?]
    public var webSocketPath: String?
    public var webSocketPort: Int?
    public var webSocketParams: [String: String?]
    public var webSocketSecure: Bool
    public let runtimeMetadataUpdateTimeoutMs: Int64
    public let namingPolicy: SubstrateClientNamingPolicy
    // TODO: object storage
    
    public init(
        rpcPath: String? = nil,
        rpcParams: [String : String?],
        webSocketPath: String? = nil,
        webSocketPort: Int? = nil,
        webSocketParams: [String : String?],
        webSocketSecure: Bool,
        runtimeMetadataUpdateTimeoutMs: Int64,
        namingPolicy: SubstrateClientNamingPolicy
    ) {
        self.rpcPath = rpcPath
        self.rpcParams = rpcParams
        self.webSocketPath = webSocketPath
        self.webSocketPort = webSocketPort
        self.webSocketParams = webSocketParams
        self.webSocketSecure = webSocketSecure
        self.runtimeMetadataUpdateTimeoutMs = runtimeMetadataUpdateTimeoutMs
        self.namingPolicy = namingPolicy
    }
    
    /// The default settings for substrate client
    /// - Returns: Settings for `SubstrateClient`
    public static func `default`() -> SubstrateClientSettings {
        .init(
            rpcParams: [:],
            webSocketParams: [:],
            webSocketSecure: false,
            runtimeMetadataUpdateTimeoutMs: 3600 * 1000,
            namingPolicy: .caseInsensitive
        )
    }
}
