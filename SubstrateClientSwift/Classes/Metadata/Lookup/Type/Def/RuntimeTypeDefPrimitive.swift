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

/// Primitive runtime type
public enum RuntimeTypeDefPrimitive: Codable {
    enum CodingKeys: Int, CodingKey {
        case bool
        case char
        case string
        case uint8
        case uint16
        case uint32
        case uint64
        case uint128
        case uint256
        case int8
        case int16
        case int32
        case int64
        case int128
        case int256
    }
    
    case bool
    case char
    case string
    case uint8
    case uint16
    case uint32
    case uint64
    case uint128
    case uint256
    case int8
    case int16
    case int32
    case int64
    case int128
    case int256
}
