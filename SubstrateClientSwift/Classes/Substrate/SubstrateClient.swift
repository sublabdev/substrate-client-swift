import Foundation
import ScaleCodecSwift

typealias RuntimeMetadataUpdates = ((RuntimeMetadata) -> Void) -> Void
typealias RuntimeMetadataSingleUpdate = () -> RuntimeMetadata?

public protocol RuntimeMetadataProvider: AnyObject {
    func runtime(_ updates: @escaping (RuntimeMetadata) -> Void, single: Bool)
    func runtimeSync() -> RuntimeMetadata
}

/// Substrate client which holds substrate lookup service; constants service and storage service.
/// Is the entering point for using those services.
public class SubstrateClient: RuntimeMetadataProvider {
    private let host: String
    private let settings: SubstrateClientSettings
    private let hashers: HashersProvider
    public let modules: ModuleRpcProvider
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
        self?.loadRuntime { runtimeMetadata, _ in
            self?.runtimeMetadata = runtimeMetadata
        }
    }
    
    private lazy var _lookupService = SubstrateLookupService(namingPolicy: settings.namingPolicy)
    let codec: ScaleCoder = ScaleCoder.default()
    
    private lazy var webSocketClient: WebSocketClient = {
        WebSocketClient(
            secure: settings.webSocketSecure,
            host: host,
            path: settings.webSocketPath,
            params: settings.webSocketParams,
            port: settings.webSocketPort
        )
    }()
    
    /// Creates a `SubstrateClient`
    /// - Parameters:
    ///     - host: host to connect to
    ///     - settings: Substrate client settings. By default is set to `default`
    public init(host: String, settings: SubstrateClientSettings = .default()) {
        self.host = host
        self.settings = settings
        let hashersProvider = DefaultHashersProvider()
        hashers = hashersProvider
        
        modules = DefaultModuleRpcProvider(
            codec: codec,
            rpcClient: RpcClient(host: host, path: settings.rpcPath, params: settings.rpcParams),
            hashersProvider: hashersProvider,
            clientQueue: settings.clientQueue,
            innerQueue: settings.innerQueue
        )
        
        codec.provideDynamicAdapter(runtimeMetadataProvider: self)
    }
    
    /// Creates a Substrate lookup service
    /// - Parameters:
    ///     - onUpdate: Completion with a `SubstrateLookupService` containing an updated `RuntimeMetadata`
    private func lookupService(_ onUpdate: @escaping (SubstrateLookupService) -> Void) {
        runtime { [weak self] runtimeMetadata in
            guard let self = self else { return }
            self._lookupService.runtimeMetadata = runtimeMetadata
            onUpdate(self._lookupService)
        }
    }
    
    /// Creates a Substrate constants service
    /// - Parameters:
    ///     - completion: Completion with `SubstrateConstantsService`
    func constantsService(completion: @escaping (SubstrateConstantsService) -> Void) {
        lookupService { [weak self] lookupService in
            guard let self = self else {
                return
            }
            
            completion(.init(codec: self.codec, lookup: lookupService, clientQueue: self.settings.clientQueue))
        }
    }
    
    /// Creates a Substrate storage service
    /// - Parameters:
    ///     - completion: Completion with `SubstrateStorageService`
    func storageService(completion: @escaping (SubstrateStorageService) -> Void) {
        lookupService { [weak self] lookupService in
            guard let self = self else {
                return
            }
            
            let storageService = SubstrateStorageService(
                lookup: lookupService,
                stateRpc: self.modules.stateRpc(),
                clientQueue: self.settings.clientQueue,
                innerQueue: self.settings.innerQueue
            )
            
            completion(storageService)
        }
    }
    
    /// Creates a Substrate extrinsics servce
    /// - Parameters:
    ///     - completion: Completion with `SubstrateExtrinsicsService`
    func extrinsicsService(completion: @escaping (SubstrateExtrinsicsService) -> Void) {
        lookupService { [weak self] lookupService in
            guard let self = self else {
                return
            }
            
            let extrinsicsService = SubstrateExtrinsicsService(
                codec: self.codec,
                lookup: lookupService,
                namingPolicy: self.settings.namingPolicy,
                clientQueue: self.settings.clientQueue
            )
            
            completion(extrinsicsService)
        }
    }
    
    /// Subscribes for metadata updates and starts a job for update it from time to time
    /// - Parameters:
    ///     - updates: Completion with an optional and updated `RuntimeMetadata`
    public func runtime(_ updates: @escaping (RuntimeMetadata) -> Void, single: Bool = false) {
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
    
    /// Get RuntimeMetadata blocking thread
    public func runtimeSync() -> RuntimeMetadata {
        let semaphore = DispatchSemaphore(value: 0)
        var runtimeMetadata: RuntimeMetadata? = nil
        DispatchQueue.global(qos: .background).async {
            self.runtime({ metadata in
                runtimeMetadata = metadata
                semaphore.signal()
            }, single: true)
        }
        
        semaphore.wait()
        return runtimeMetadata!
    }
    
    /// Loads runtime metadata
    /// - Parameters:
    ///     - completion: Completion with either an optional `RuntimeMetadata` or optional `RpcError`
    private func loadRuntime(completion: @escaping (RuntimeMetadata?, RpcError?) -> Void) {
        modules.stateRpc().getRuntimeMetadata(completion: completion)
    }
}
