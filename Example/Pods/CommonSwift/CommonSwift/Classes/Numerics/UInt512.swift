import Foundation
import BigInt

/// `UInt512` wrapper over `BigInt`
public struct UInt512: Codable, Equatable {
    let value: BigUInt
    public static let size = 64
    
    /// Creates `UInt512` wrapper over `BigInt`
    /// - Parameters:
    ///     - value: Value of type `BigInt`
    public init(value: BigUInt) {
        self.value = value
    }
    
    /// Creates `UInt512` wrapper over BigInt using `String`. This initializer can fail.
    /// - Parameters:
    ///     - string: A `String` value
    public init?(_ string: String) {
        guard let value = BigUInt(string) else { return nil }
        self.value = value
    }
    
    /// Creates `UInt512` wrapper over BigInt using `UInt64`
    /// - Parameters:
    ///     - string: An `UInt64` value
    public init(_ integer: UInt64) {
        value = BigUInt(integerLiteral: integer)
    }
}

extension UInt512 {
    /// Converts `UInt512` into `Data`
    /// - Returns: `Data` from `UInt512`'s value
    public func data() -> Data {
        value.serialize().copyOf(size: byteSize(byteSizeType: .uInt512))
    }
}

extension Data {
    /// Generates `UInt512` from `Data`
    /// - Returns: `UInt512` from `Data`
    public func uInt512() -> UInt512 {
        UInt512(value: BigUInt(self))
    }
}

extension String {
    /// Generates `UInt512` from `String`
    /// - Returns: `UInt512` from `String`
    public func uInt512() -> UInt512? {
        UInt512(self)
    }
}
