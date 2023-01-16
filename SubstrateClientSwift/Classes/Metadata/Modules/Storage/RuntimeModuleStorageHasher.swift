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

/// Runtime module storage hasher types
public enum RuntimeModuleStorageHasher: Codable {
    enum CodingKeys: Int, CodingKey {
        case blake128
        case blake256
        case blake128Concat
        case twox128
        case twox256
        case twox64Concat
        case identity
    }
    
    case blake128
    case blake256
    case blake128Concat
    case twox128
    case twox256
    case twox64Concat
    case identity
}
