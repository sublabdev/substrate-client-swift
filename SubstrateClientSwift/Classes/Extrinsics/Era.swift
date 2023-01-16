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

/// An extrinsic era
public enum Era: Equatable, Codable {
    enum CodingKeys: Int, CodingKey {
        case immortal = 0
        case mortal = 1
    }
    
    case immortal
    case mortal(value: Mortal)
}

/// Mortal era value
public struct Mortal: Equatable, Codable {
    public let period: UInt64
    public let phase: UInt64
}
