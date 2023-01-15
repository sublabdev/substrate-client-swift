/**
 *
 * Copyright 2023 SUBSTRATE LABORATORY LLC <info@sublab.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

import Foundation
import ScaleCodecSwift

/// Substrate constants service. Handles fetching runtime module constant
public class SubstrateConstantsService {
    enum ConstantServiceError: Error {
        case noResult
        case fetchingFailure
    }
    
    private weak var codec: ScaleCoder?
    private weak var lookup: SubstrateLookup?
    
    /// Creates Substrate constants service
    /// - Parameters:
    ///     - codec: Scale coder that is used to decode the received data
    ///     - lookup: Substrate lookup service
    init(codec: ScaleCoder?, lookup: SubstrateLookup?) {
        self.codec = codec
        self.lookup = lookup
    }
    
    /// Finds a runtime module constant by the constant's name in a specified module
    /// - Parameters:
    ///     - moduleName: Module's name in which the constant should be looked for
    ///     - constantName: Constant name by which the constant should be found
    /// - Returns: A runtime module constant on a client-specified queue
    public func find(
        moduleName: String,
        constantName: String
    ) async throws -> RuntimeModuleConstant? {
        try await lookup?.findConstant(moduleName: moduleName, constantName: constantName)
    }
    
    /// Fetches a generic `T`, conforming to `Decodable`, from a runtime module constant
    /// - Parameters:
    ///     - moduleName: Module's name in which the constant should be looked for
    ///     - constantName: Constant name by which the constant should be found
    /// - Returns: A generic `T` from a module constant
    public func fetch<T: Decodable>(
        moduleName: String,
        constantName: String
    ) async throws -> T? {
        guard let constant = try await find(moduleName: moduleName, constantName: constantName) else { return nil }
        return try fetch(T.self, constant: constant)
    }
    
    /// Decodes the value bytes of a runtime module constant into a specified type
    /// - Parameters:
    ///     - type: The type to decode to
    ///     - constant: Runtime module constant which value bytes are being decoded to generic type `T`
    /// - Returns: Decoded generic type `T`
    public func fetch<T: Decodable>(_ type: T.Type, constant: RuntimeModuleConstant) throws -> T? {
        try codec?.decoder.decode(T.self, from: Data(constant.valueBytes))
    }
}
