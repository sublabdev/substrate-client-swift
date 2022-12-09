import Foundation
import BigInt

/// UInt128 wrapper over BigInt
public struct UInt128: Codable, Equatable {
    public let value: BigUInt
    public static let size = 16
    
    /// Creates UInt128 wrapper over BigInt
    /// - Parameters:
    ///     - value: Value of type BigInt
    public init(value: BigUInt) {
        self.value = value
    }
}

extension UInt128 {
    /// Converts UInt128 into Data
    /// - Returns: Data from UInt128's `value`
    public func data() -> Data {
        value.serialize().copyOf(size: byteSize(byteSizeType: .uInt128))
    }
}

extension Data {
    /// Generates UInt128 from Data
    /// - Returns: UInt128 from Data
    public func uInt128() -> UInt128 {
        UInt128(value: BigUInt(self))
    }
}
