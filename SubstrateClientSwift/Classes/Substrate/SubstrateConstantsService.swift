import Foundation
import ScaleCodecSwift

/// Substrate constants service. Handles fetching runtime module constant
class SubstrateConstantsService {
    enum ConstantServiceError: Error {
        case noResult
        case fetchingFailure
    }
    
    private let codec: ScaleCoder
    private let lookup: SubstrateLookupService
    private let clientQueue: DispatchQueue
    
    /// Creates Substrate constants service
    /// - Parameters:
    ///     - codec: Scale coder that is used to decode the received data
    ///     - lookup: Substrate lookup service
    ///     - clientQueue: A queue specified by client on which the results should be returned
    init(codec: ScaleCoder, lookup: SubstrateLookupService, clientQueue: DispatchQueue) {
        self.codec = codec
        self.lookup = lookup
        self.clientQueue = clientQueue
    }
    
    /// Finds a runtime module constant by the constant's name in a specified module
    /// - Parameters:
    ///     - moduleName: Module's name in which the constant should be looked for
    ///     - constantName: Constant name by which the constant should be found
    ///     - completion: Contains a runtime module on a client-specified queue
    func find(
        moduleName: String,
        constantName: String,
        completion: @escaping (RuntimeModuleConstant?) throws -> Void
    ) throws {
        let runtimeModuleConstant = try lookup.findConstant(moduleName: moduleName, constantName: constantName)
        try completion(runtimeModuleConstant)
    }
    
    /// Finds a runtime module constant by the constant's name in a specified module and returns its value bytes
    /// decoded into a specified type
    /// - Parameters:
    ///     - moduleName: Module's name in which the constant should be looked for
    ///     - constantName: Constant name by which the constant should be found
    ///     - completion: A completion with a result returned on a user-specified queue
    func fetch<T: Decodable>(
        moduleName: String,
        constantName: String,
        completion: @escaping (T?) -> Void
    ) throws {
        try find(moduleName: moduleName, constantName: constantName) { [weak self] runtimeModuleConstant in
            guard let self = self, let runtimeModuleConstant = runtimeModuleConstant else {
                completion(nil)
                return
            }
            
            let runtimeModule = try self.fetch(T.self, constant: runtimeModuleConstant)
            
            self.clientQueue.async {
                completion(runtimeModule)
            }
        }
    }
    
    /// Decodes the value bytes of a runtime module constant into a specified type
    /// - Parameters:
    ///     - type: The type to decode to
    ///     - constant: Runtime module constant which value bytes are being decoded to generic type `T`
    /// - Returns: Decoded generic type `T`
    func fetch<T: Decodable>(_ type: T.Type, constant: RuntimeModuleConstant) throws -> T {
        try codec.decoder.decode(T.self, from: Data(constant.valueBytes))
    }
}
