import Foundation
import Base58Swift

/// Base58 String decoder
public struct StringBase58 {
    private let string: String
    
    public init(string: String) {
        self.string = string
    }
    
    /// Decodes String using Base58
    /// - Returns: A decoded data based on Base58
    public func decode() -> Data {
        guard let decodedValue = Base58.base58Decode(string) else {
            return Data()
        }
        
        return Data(decodedValue)
    }
}

extension String {
    /// A point of access to Base58 functionality for String
    public var base58: StringBase58 {
        .init(string: self)
    }
}
