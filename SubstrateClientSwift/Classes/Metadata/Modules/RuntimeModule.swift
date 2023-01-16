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

import BigInt
import Foundation

/// Runtime module
public class RuntimeModule: Codable {
    public let name: String
    public let storage: RuntimeModuleStorage?
    public let callIndex: BigUInt?
    public let eventsIndex: BigUInt?
    public let constants: [RuntimeModuleConstant]
    public let errorsIndex: BigUInt?
    public let index: UInt8
    
    public init(
        name: String,
        storage: RuntimeModuleStorage?,
        callIndex: BigUInt?,
        eventsIndex: BigUInt?,
        constants: [RuntimeModuleConstant],
        errorsIndex: BigUInt?,
        index: UInt8
    ) {
        self.name = name
        self.storage = storage
        self.callIndex = callIndex
        self.eventsIndex = eventsIndex
        self.constants = constants
        self.errorsIndex = errorsIndex
        self.index = index
    }
}
