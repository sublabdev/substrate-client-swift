import BigInt
import Foundation

/// Tuple runtime type
public struct RuntimeTypeDefTuple: Codable {
    let types: [BigUInt]
}
