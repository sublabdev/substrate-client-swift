import BigInt
import Foundation

/// Bit sequence runtime type
public struct RuntimeTypeDefBitSequence: Codable {
    let store: BigUInt
    let order: BigUInt
}
