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
import CommonSwift
import Foundation

/// Runtime lookup. Holds an array of lookup items
public final class RuntimeLookup: Codable {
    public let items: [RuntimeLookupItem]

    private var itemsByIndices: [(BigUInt, RuntimeType)] {
        items.enumerated().map { (BigUInt($0), $1.type) }
    }
    
    public init(items: [RuntimeLookupItem]) {
        self.items = items
    }
    
    /// Finds a lookup item by an index of type BigUInt
    /// - Parameters:
    ///     - index: Index to find a lookup item
    /// - Returns: A lookup item for a specific index
    public func findItem(by index: BigUInt) -> RuntimeType? {
        itemsByIndices.first { $0.0 == index }?.1
    }
    
    /// Returns a runtime type based on an index
    /// - Parameters:
    ///     - index: Index to find a runtime type
    /// - Returns: A runtime type for the provided index
    public func findItemByIndex(_ index: Int) -> RuntimeType? {
        findItem(by: BigUInt(index))
    }
}
