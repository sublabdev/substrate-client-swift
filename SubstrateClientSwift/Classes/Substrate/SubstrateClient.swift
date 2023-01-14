import Foundation
import ScaleCodecSwift

public protocol RuntimeMetadataProvider: AnyObject {
    func runtimeMetadata() async throws -> RuntimeMetadata
    func runtimeMetadata(_ updates: @escaping (RuntimeMetadata) -> Void, single: Bool)
}

/// Substrate client which holds substrate lookup service; constants service and storage service.
/// Is the entering point for using those services.
public class SubstrateClient: RuntimeMetadataProvider {
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
        self?.runtimeMetadata = try await self?.modules.stateRpc.runtimeMetadata()
    }
    
    private let _modules: InternalModuleRpcProvider
    public var modules: ModuleRpcProvider { _modules }
    
    private let _lookup: InternalSubstrateLookup
    public var lookup: SubstrateLookup { _lookup }
    
    public let constants: SubstrateConstantsService
    public let storage: SubstrateStorageService
    
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
        
        let modules = DefaultModuleRpcProvider(
            codec: codec,
            rpcClient: RpcClient(host: host, path: settings.rpcPath, params: settings.rpcParams),
            hashersProvider: hashersProvider
        )
        self._modules = modules
        
        self._lookup = SubstrateLookupService(namingPolicy: settings.namingPolicy)
        self.constants = .init(codec: self.codec, lookup: self._lookup)
        self.storage = .init(lookup: self._lookup, stateRpc: modules.stateRpc)
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
