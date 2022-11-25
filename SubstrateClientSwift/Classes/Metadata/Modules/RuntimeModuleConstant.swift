import BigInt
import Foundation

// TODO: Make public everyting related to metadata

struct RuntimeModuleConstant: Codable {
    let name: String
    let type: BigUInt
    let valueBytes: [UInt8]
    let docs: [String]
}
