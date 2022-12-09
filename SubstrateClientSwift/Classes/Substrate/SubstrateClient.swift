import Foundation
import ScaleCodecSwift
import Combine

/// Substrate client which holds substrate lookup service; constants service and storage service.
/// Is the entering point for using those services.
class SubstrateClient {
    private let url: URL
    private let settings: SubstrateClientSettings
    private let hashers: HashersProvider
    let module: ModuleRpcProvider
    private let runtimeMetadata: PassthroughSubject<RuntimeMetadata?, Never>
    private var timer : DispatchSourceTimer?
    private var getRutimeDispatchWorkItem: DispatchWorkItem?
    
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
        runtimeMetadata = settings.objectStorageFactory.make()
        let hashersProvider = DefaultHashersProvider()
        hashers = hashersProvider
        
        module = DefaultModuleRpcProvider(
            codec: codec,
            rpcClient: RpcClient(url: url),
            hashersProvider: hashersProvider
        )
    }
    
    /// Creates a Substrate lookup service
    /// - Returns: Substrate lookup service
    func lookupService() -> SubstrateLookupService {
        SubstrateLookupService(runtimeMetadata: getRuntime(), namingPolicy: settings.namingPolicy)
    }
    /// Creates a Substrate constants service
    /// - Returns: Substrate constants service
    func constantsService() -> SubstrateConstantsService {
        SubstrateConstantsService(codec: codec, lookup: lookupService())
    }
    /// Creates a Substrate storage service
    /// - Returns: Substrate storage service
    func storageService() -> SubstrateStorageService {
        SubstrateStorageService(lookup: lookupService(), stateRpc: module.stateRpc())
    }
    
    // MARK: - Private
    /// Gets the runtime metadata, sends it to a `PassthroughSubject` and returns that subject
    private func getRuntime() -> PassthroughSubject<RuntimeMetadata?, Never> {
        loadRuntime { [weak self] result, error in
            guard error == nil else { return }
            self?.runtimeMetadata.send(result)
        }
        
        return runtimeMetadata
    }
    
    /// Gets runtime metadata
    /// - Parameters:
    ///     - completion: Completion with either an optional `RuntimeMetadata` or optional `RpcError`
    private func loadRuntime(completion: @escaping (RuntimeMetadata?, RpcError?) -> Void) {
        module.stateRpc().getRuntimeMetadata(completion: completion)
    }
}
