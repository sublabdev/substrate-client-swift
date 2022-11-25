import BigInt
import Foundation

struct RuntimeTypeDefField: Codable {
    let name: String?
    let type: BigUInt
    let typeName: String?
    let docs: [String]
}
