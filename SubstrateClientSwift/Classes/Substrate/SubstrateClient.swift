import Foundation
import ScaleCodecSwift

/// Substrate client which holds substrate lookup service; constants service and storage service.
/// Is the entering point for using those services.
class SubstrateClient {
    private let url: URL
    private let settings: SubstrateClientSettings
    private let hashers: HashersProvider
    let module: ModuleRpcProvider
    private var timer : DispatchSourceTimer?
    private var getRutimeDispatchWorkItem: DispatchWorkItem?
    private var lookupService: SubstrateLookupService?
    private var subscribers: [(RuntimeMetadata?) -> Void] = []
    
    private weak var runtimeMetadata: RuntimeMetadata? = nil {
        didSet {
            subscribers.forEach { $0(runtimeMetadata) }
        }
    }
    
    private lazy var runtimeMetadataUpdateJob: JobWithTimeout
        = JobWithTimeout(timeout: TimeInterval(settings.runtimeMetadataUpdateTimeoutMs)) { [weak self] in
            self?.loadRuntime { runtimeMetadata, _ in
                self?.runtimeMetadata = runtimeMetadata
            }
    }
    
    private lazy var _lookupService = SubstrateLookupService(namingPolicy: settings.namingPolicy)
    
    let codec: ScaleCoder = ScaleCoder.default()
    
    private lazy var webSocketClient: WebSocketClient = {
        WebSocketClient(
            host: url,
            path: settings.webSocketPath,
            port: settings.webSocketPort,
            settings: .init(policy: .none)
        )
    }()
    
    /// Creates a `SubstrateClient`
    /// - Parameters:
    ///     - url: URL to get data from
    ///     - settings: Substrate client settings. By default is set to `default`
    init(url: URL, settings: SubstrateClientSettings = .default()) {
        self.url = url
        self.settings = settings
        let hashersProvider = DefaultHashersProvider()
        hashers = hashersProvider
        
        module = DefaultModuleRpcProvider(
            codec: codec,
            rpcClient: RpcClient(url: url),
            hashersProvider: hashersProvider
        )
    }
    
    // Creates a Substrate lookup service
    /// - Parameters:
    ///     - onUpdate: Completion with a `SubstrateLookupService` containing an updated `RuntimeMetadata`
    public func lookupService(_ onUpdate: @escaping (SubstrateLookupService) -> Void) {
        runtime { [weak self] runtimeMetadata in
            guard let self = self, let runtimeMetadata = runtimeMetadata else { return }
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
            
            completion(.init(codec: self.codec, lookup: lookupService))
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
            
            completion(.init(lookup: lookupService, stateRpc: self.module.stateRpc()))
        }
    }
    
    /// Creates a Substrate extrinsics servce
    /// - Parameters:
    ///     - completion: Completion with `SubstrateExtrinsicsService`
    func extrinsicService(completion: @escaping (SubstrateExtrinsicsService) -> Void) {
        lookupService { [weak self] lookupService in
            guard let self = self else {
                return
            }
            
            completion(.init(codec: self.codec, lookup: lookupService, namingPolicy: self.settings.namingPolicy))
        }
    }
    
    /// Subscribes for metadata updates and starts a job for update it from time to time
    /// - Parameters:
    ///     - completion: Completion with an optional and updated `RuntimeMetadata`
    public func runtime(_ updates: @escaping (RuntimeMetadata?) -> Void) {
        subscribers.append(updates)
        runtimeMetadataUpdateJob.performIfNeeded()
        updates(runtimeMetadata)
    }
    
    /// Loads runtime metadata
    /// - Parameters:
    ///     - completion: Completion with either an optional `RuntimeMetadata` or optional `RpcError`
    private func loadRuntime(completion: @escaping (RuntimeMetadata?, RpcError?) -> Void) {
        module.stateRpc().getRuntimeMetadata(completion: completion)
    }
}
