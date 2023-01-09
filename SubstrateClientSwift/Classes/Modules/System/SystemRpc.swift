import Foundation

protocol SystemRpc {
    func runtimeVersion(completion: @escaping (RuntimeVersion?) -> Void) throws
}

class SystemRpcClient: SystemRpc {
    private let constantsService: SubstrateConstantsService
    
    init(constantsService: SubstrateConstantsService) {
        self.constantsService = constantsService
    }
    
    func runtimeVersion(completion: @escaping (RuntimeVersion?) -> Void) throws {
        try constantsService.fetch(moduleName: "system", constantName: "version") { runtimeVersion in
            completion(runtimeVersion)
        }
    }
}
