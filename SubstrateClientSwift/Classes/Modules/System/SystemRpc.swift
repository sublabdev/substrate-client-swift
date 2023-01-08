import Foundation

protocol SystemRpc {
    func runtimeVersion() throws -> RuntimeVersion?
}

class SystemRpcClient: SystemRpc {
    private let constantsService: SubstrateConstantsService
    
    init(constantsService: SubstrateConstantsService) {
        self.constantsService = constantsService
    }
    
    func runtimeVersion() throws -> RuntimeVersion? {
        try constantsService.fetch(moduleName: "system", constantName: "version")
    }
}
