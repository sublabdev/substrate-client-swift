import Foundation

/// An interface for fetching runtime version and account
protocol SystemRpc {
    /// Gets runtime version
    /// - Parameters:
    ///     - completion: Completion with an optiional runtime version
    func runtimeVersion(completion: @escaping (RuntimeVersion?) -> Void) throws
    /// Gets account
    /// - Parameters:
    ///     - completion: Completion with either an optional `Account` or with an optional `RpcError`
    func account(completion: @escaping (Account?, RpcError?) -> Void)
}

public class SystemRpcClient: SystemRpc {
    private let constantsService: SubstrateConstantsService
    private let storageService: SubstrateStorageService
    
    init(constantsService: SubstrateConstantsService, storageService: SubstrateStorageService) {
        self.constantsService = constantsService
        self.storageService = storageService
    }
    
    func runtimeVersion(completion: @escaping (RuntimeVersion?) -> Void) throws {
        try constantsService.fetch(moduleName: "system", constantName: "version") { runtimeVersion in
            completion(runtimeVersion)
        }
    }
    
    func account(completion: @escaping (Account?, RpcError?) -> Void) {
        storageService.fetch(moduleName: "system", itemName: "account") { (response: Account?, error: RpcError?) in
            completion(response, error)
        }
    }
}
