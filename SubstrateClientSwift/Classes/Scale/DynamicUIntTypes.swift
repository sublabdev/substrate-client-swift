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
