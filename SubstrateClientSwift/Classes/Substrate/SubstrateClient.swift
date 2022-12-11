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
    private lazy var runtimeMetadataUpdateJob: JobWithTimeout = {
        JobWithTimeout(timeout: TimeInterval(settings.runtimeMetadataUpdateTimeoutMs)) { [weak self] in
            guard let `self` = self else { return }
            
            self.loadRuntime { runtimeMetadata, _ in
                if let lookupService = self.lookupService {
                    lookupService.updateLookupService(with: runtimeMetadata)
                } else {
                    self.lookupService = SubstrateLookupService(
                        runtimeMetadata: runtimeMetadata,
                        namingPolicy: self.settings.namingPolicy
                    )
                }
            }
        }
    } ()
    
    var codec: ScaleCoder = {
        ScaleCoder.defaultCoder()
    }()
    
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
    
    /// Creates a Substrate lookup service
    /// - Parameters:
    ///     - completion: Completion with either an optional `SubstrateLookupService` or optional `RpcError`
    func lookupService(completion: @escaping (SubstrateLookupService?, RpcError?) -> Void) {
        getRuntime { [weak self] result, rpcError in
            guard let `self` = self, rpcError == nil else {
                completion(nil, rpcError)
                return
            }
            
            let lookupService = SubstrateLookupService(
                runtimeMetadata: result,
                namingPolicy: self.settings.namingPolicy
            )
            
            self.lookupService = lookupService
            completion(lookupService, nil)
            
            // Start updating the metadata
            self.runtimeMetadataUpdateJob.performIfNeeded()
        }
    }
    /// Creates a Substrate constants service
    /// - Parameters:
    ///     - completion: Completion with either an optional `SubstrateConstantsService` or optional `RpcError`
    func constantsService(completion: @escaping (SubstrateConstantsService?, RpcError?) -> Void) {
        lookupService { [weak self] lookupService, rpcError in
            guard let `self` = self, rpcError == nil else {
                completion(nil, rpcError)
                return
            }
            
            guard let lookupService = lookupService else {
                completion(nil, .responseError(.noData))
                return
            }
            
            completion(.init(codec: self.codec, lookup: lookupService), nil)
        }
    }
    /// Creates a Substrate storage service
    /// - Parameters:
    ///     - completion: Completion with either an optional `SubstrateStorageService` or optional `RpcError`
    func storageService(completion: @escaping (SubstrateStorageService?, RpcError?) -> Void) {
        lookupService { [weak self] lookupService, rpcError in
            guard let `self` = self, rpcError == nil else {
                completion(nil, rpcError)
                return
            }
            
            guard let lookupService = lookupService else {
                completion(nil, .responseError(.noData))
                return
            }
            
            completion(.init(lookup: lookupService, stateRpc: self.module.stateRpc()), nil)
        }
    }
    
    // MARK: - Private
    // Gets runtime metadata
    /// - Parameters:
    ///     - completion: Completion with either an optional `RuntimeMetadata` or optional `RpcError`
    private func getRuntime(completion: @escaping (RuntimeMetadata?, RpcError?) -> Void) {
        loadRuntime(completion: completion)
    }
    
    /// Loads runtime metadata
    /// - Parameters:
    ///     - completion: Completion with either an optional `RuntimeMetadata` or optional `RpcError`
    private func loadRuntime(completion: @escaping (RuntimeMetadata?, RpcError?) -> Void) {
        module.stateRpc().getRuntimeMetadata(completion: completion)
    }
}
