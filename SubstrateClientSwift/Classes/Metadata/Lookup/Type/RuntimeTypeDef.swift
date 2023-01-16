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

/// Runtime type definition
public enum RuntimeTypeDef: Codable {
    enum CodingKeys: Int, CodingKey {
        case composite
        case variant
        case sequence
        case array
        case tuple
        case primitive
        case compact
        case bitSequence
    }
    
    case composite(RuntimeTypeDefComposite)
    case variant(RuntimeTypeDefVariant)
    case sequence(RuntimeTypeDefSequence)
    case array(RuntimeTypeDefArray)
    case tuple(RuntimeTypeDefTuple)
    case primitive(RuntimeTypeDefPrimitive)
    case compact(RuntimeTypeDefCompact)
    case bitSequence(RuntimeTypeDefBitSequence)
}
