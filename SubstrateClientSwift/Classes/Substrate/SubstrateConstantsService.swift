import Foundation
import ScaleCodecSwift
import Combine

/// Substrate constants service. Handles fetching runtime module constant
class SubstrateConstantsService {
    enum ConstantServiceError: Error {
        case noResult
        case fetchingFailure
    }
    
    private let codec: ScaleCoder
    private let lookup: SubstrateLookupService
    private var anyCancellable = Set<AnyCancellable>()
    
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
    /// - Returns: `AnyPublisher` with an optional `RuntimeModuleConstant`
    func find(moduleName: String, constantName: String) -> AnyPublisher<RuntimeModuleConstant?, Never> {
        lookup.findConstant(moduleName: moduleName, constantName: constantName)
    }
    
    /// Fetches a runtime module constant by the constant's name in a specified module
    /// - Parameters:
    ///     - moduleName: Module's name in which the constant should be looked for
    ///     - constantName: Constant name by which the constant should be found
    ///     - completion: The completion with either an optional result of generic type`T` or
    ///     optional `ConstantServiceError`
    func fetch<T: Decodable>(
        moduleName: String,
        constantName: String,
        completion: @escaping (T?, ConstantServiceError?) -> Void
    ) {
        find(moduleName: moduleName, constantName: constantName)
            .sink { [weak self] result in
                guard let result = result else {
                    completion(nil, .noResult)
                    return
                }
                
                do {
                    let fetchedValue = try self?.fetch(T.self, constant: result)
                    completion(fetchedValue, nil)
                } catch {
                    completion(nil, .fetchingFailure)
                }
            }
            .store(in: &anyCancellable)
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
