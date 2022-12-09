import BigInt
import Foundation

/// Runtime type field
struct RuntimeTypeDefField: Codable {
    let name: String?
    let type: BigUInt
    let typeName: String?
    let docs: [String]
}
