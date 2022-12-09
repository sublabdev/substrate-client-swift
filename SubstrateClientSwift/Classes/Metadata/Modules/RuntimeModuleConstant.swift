import BigInt
import Foundation

/// Runtime module constant
public struct RuntimeModuleConstant: Codable {
    let name: String
    let type: BigUInt
    let valueBytes: [UInt8]
    let docs: [String]
}
