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

/// Runtime module storage item
public class RuntimeModuleStorageItem: Codable {
    public let name: String
    public let modifier: RuntimeModuleStorageItemModifier
    public let type: RuntimeModuleStorageItemType
    public var fallbackBytes: [UInt8]
    public let docs: [String]
    
    init(
        name: String,
        modifier: RuntimeModuleStorageItemModifier,
        type: RuntimeModuleStorageItemType,
        fallbackBytes: [UInt8], docs: [String]
    ) {
        self.name = name
        self.modifier = modifier
        self.type = type
        self.fallbackBytes = fallbackBytes
        self.docs = docs
    }
}
