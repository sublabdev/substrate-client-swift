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
    
    /// Creates Substrate constants service
    /// - Parameters:
    ///     - codec: Scale coder that is used to decode the received data
    ///     - lookup: Substrate lookup service
    init(codec: ScaleCoder, lookup: SubstrateLookupService) {
        self.codec = codec
        self.lookup = lookup
    }
    
    /// Finds a runtime module constant by the constant's name in a specified module
    /// - Parameters:
    ///     - moduleName: Module's name in which the constant should be looked for
    ///     - constantName: Constant name by which the constant should be found
    /// - Returns: A runtime module constant
    func find(
        moduleName: String,
        constantName: String
    ) throws -> RuntimeModuleConstant? {
        try lookup.findConstant(moduleName: moduleName, constantName: constantName)
    }
    
    /// Fetches a runtime module constant by the constant's name in a specified module
    /// - Parameters:
    ///     - moduleName: Module's name in which the constant should be looked for
    ///     - constantName: Constant name by which the constant should be found
    /// - Returns: A runtime module constant
    func fetch<T: Decodable>(
        moduleName: String,
        constantName: String
    ) throws -> T? {
        guard let runtimeModuleConstant = try find(moduleName: moduleName, constantName: constantName) else {
            return nil
        }
        
        return try fetch(T.self, constant: runtimeModuleConstant)
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
