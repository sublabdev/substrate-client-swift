import BigInt
import Foundation

/// Array runtime type
public struct RuntimeTypeDefArray: Codable {
    let length: UInt32
    let type: BigUInt
}
