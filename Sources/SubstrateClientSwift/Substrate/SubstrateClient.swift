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
import ScaleCodecSwift

public protocol RuntimeMetadataProvider: AnyObject {
    func runtimeMetadata() async throws -> RuntimeMetadata
    func runtimeMetadata(_ updates: @escaping (RuntimeMetadata) -> Void, single: Bool)
}

/// Substrate client which holds substrate lookup service; constants service, storage service, and extrinsic service.
/// It's the entry point for using those services.
public final class SubstrateClient: RuntimeMetadataProvider {
    private let host: String
    private let settings: SubstrateClientSettings
    private let hashers: HashersProvider
    private var getRutimeDispatchWorkItem: DispatchWorkItem?
    private var subscribers: [(RuntimeMetadata) -> Void] = []
    
    private var runtimeMetadata: RuntimeMetadata? = nil {
        didSet {
            if let runtimeMetadata = runtimeMetadata {
                subscribers.forEach { $0(runtimeMetadata) }
            }
        }
    }
    
    private lazy var runtimeMetadataUpdateJob = JobWithTimeout(
        timeout: TimeInterval(settings.runtimeMetadataUpdateTimeoutMs)
    ) { [weak self] in
        self?.runtimeMetadata = try await self?.modules.state.runtimeMetadata()
    }
    
    private let _modules: InternalModuleProvider
    public var modules: ModuleProvider { _modules }
    
    private let _lookup: InternalSubstrateLookup
    public var lookup: SubstrateLookup { _lookup }
    
    public let constants: SubstrateConstants
    public let storage: SubstrateStorage
    
    private let _extrinsics: InternalSubstrateExtrinsics
    public var extrinsics: SubstrateExtrinsics { _extrinsics }
    
    let codec: ScaleCoder = ScaleCoder.default()
    
    private lazy var webSocketClient = WebSocketClient(
        secure: settings.webSocketSecure,
        host: host,
        path: settings.webSocketPath,
        params: settings.webSocketParams,
        port: settings.webSocketPort
    )
    
    /// Creates a `SubstrateClient`
    /// - Parameters:
    ///     - host: host to connect to
    ///     - settings: Substrate client settings. By default is set to `default`
    public init(host: String, settings: SubstrateClientSettings = .default()) {
        self.host = host
        self.settings = settings
        let hashersProvider = DefaultHashersProvider()
        self.hashers = hashersProvider
        
        let modules = DefaultModuleProvider(
            codec: codec,
            rpcClient: RpcClient(host: host, path: settings.rpcPath, params: settings.rpcParams),
            hashersProvider: hashersProvider
        )
        self._modules = modules
        
        self._lookup = SubstrateLookupService(namingPolicy: settings.namingPolicy)
        
        self.constants = SubstrateConstantsService(
            codec: self.codec,
            lookup: self._lookup
        )
        
        self.storage = SubstrateStorageService(
            lookup: self._lookup,
            stateRpc: modules.state
        )
        
        self._extrinsics = SubstrateExtrinsicsService(
            modules: modules,
            codec: codec,
            lookup: self._lookup,
            namingPolicy: settings.namingPolicy
        )
        
        self._lookup.runtimeMetadataProvider = self
        self._modules.constants = self.constants
        self._modules.storage = self.storage
        self._extrinsics.runtimeMetadataProvider = self
        self.codec.provideDynamicAdapter(runtimeMetadataProvider: self)
    }
    
    /// Subscribes for metadata updates and starts a job for update it from time to time
    /// - Parameters:
    ///     - updates: Completion with an optional and updated `RuntimeMetadata`
    public func runtimeMetadata(_ updates: @escaping (RuntimeMetadata) -> Void, single: Bool = false) {
        if single, let runtimeMetadata = runtimeMetadata {
            updates(runtimeMetadata)
            return
        }
        
        subscribers.append(updates)
        runtimeMetadataUpdateJob.performIfNeeded()
        
        if let runtimeMetadata = runtimeMetadata {
            updates(runtimeMetadata)
        }
    }
    
    /// Get RuntimeMetadata blocking the current thread
    /// - Returns: A runtime metadata
    public func runtimeMetadata() async throws -> RuntimeMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.runtimeMetadata({ runtimeMetadata in
                continuation.resume(returning: runtimeMetadata)
            }, single: true)
        }
    }
}
