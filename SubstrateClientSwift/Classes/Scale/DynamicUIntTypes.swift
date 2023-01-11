import BigInt
import Foundation

// MARK: - Index

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
    
    public func toData() -> Data {
        Data(value.serialize().reversed())
    }
}

// MARK: - Balance

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
    
    public func toData() -> Data {
        Data(value.serialize().reversed())
    }
}
