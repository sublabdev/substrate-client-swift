import Foundation
import Base58Swift

/// Base58 Data encoder
public struct DataBase58 {
    private let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    /// Encodes Data using Base58
    /// - Returns: An encoded String based on Base58
    public func encode() -> String {
        Base58.base58Encode(Array(data))
    }
}

extension Data {
    /// A point of access to Base58 functionality for Data
    public var base58: DataBase58 {
        .init(data: self)
    }
}
