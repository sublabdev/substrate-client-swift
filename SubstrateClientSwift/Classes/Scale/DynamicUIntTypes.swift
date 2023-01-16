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

// MARK: - Index

/// Index with a value of type `BigUInt. Conforms to `DynamicType`, and hence contains a lookup index.
public struct Index: DynamicType, Codable {
    public let value: BigUInt
    
    public init(value: BigUInt) {
        self.value = value
    }
}

// MARK: - Index + DynamicType

extension Index {
    public static var lookupIndex: Int { 4 }
    
    public init(data: Data) {
        self.value = BigUInt(Data(data.reversed()))
    }
    
    /// Converts value into `Data`
    /// - Returns: `Data` from the `value`
    public func toData() -> Data {
        Data(value.serialize().reversed())
    }
}

// MARK: - Balance

/// Balance. It's `value` is of type `BigUInt`. Conforms to `DynamicType` and contains a lookup index
public struct Balance {
    public let value: BigUInt
    public init(value: BigUInt) {
        self.value = value
    }
}

// MARK: - Balance + DynamicType

extension Balance: DynamicType {
    public static var lookupIndex: Int { 6 }
    
    public init(data: Data) {
        self.value = BigUInt(Data(data.reversed()))
    }
    
    /// Converts value into `Data`
    /// - Returns: `Data` from the `value`
    public func toData() -> Data {
        Data(value.serialize().reversed())
    }
}
