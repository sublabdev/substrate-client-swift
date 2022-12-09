import BigInt
import Foundation

/// Runtime type parametr
public struct RuntimeTypeParam: Codable {
    let name: String
    let type: BigUInt?
}
