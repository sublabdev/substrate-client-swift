import Foundation
import BigInt

/// Int128 wrapper over BigInt
public struct Int128: Codable, Equatable {
    let value: BigInt
    public static let size = 16
    
    /// Creates Int128 wrapper over BigInt
    /// - Parameters:
    ///     - value: Value of type BigInt
    public init(value: BigInt) {
        self.value = value
    }
}

extension Int128 {
    /// Converts Int128 into Data
    /// - Returns: Data from Int128's `value`
    public func data() -> Data {
        value.serialize().copyOf(size: byteSize(byteSizeType: .int128))
    }
}

extension Data {
    /// Generates Int128 from Data
    /// - Returns: Int128 from Data
    public func int128() -> Int128 {
        Int128(value: BigInt(self))
    }
}
