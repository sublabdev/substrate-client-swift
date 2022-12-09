import Foundation
import BigInt

/// Int512 wrapper over BigInt
public struct Int512: Codable, Equatable {
    let value: BigInt
    public static let size = 64
    
    /// Creates Int512 wrapper over BigInt
    /// - Parameters:
    ///     - value: Value of type BigInt
    public init(value: BigInt) {
        self.value = value
    }
}

extension Int512 {
    /// Converts Int512 into Data
    /// - Returns: Data from Int512's `value`
    public func data() -> Data {
        value.serialize().copyOf(size: byteSize(byteSizeType: .int512))
    }
}

extension Data {
    /// Generates Int512 from Data
    /// - Returns: Int512 from Data
    public func int512() -> Int512 {
        Int512(value: BigInt(self))
    }
}
