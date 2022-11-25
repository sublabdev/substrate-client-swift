import BigInt
import Foundation

struct RuntimeMetadata: Codable {
    let magicNumber: UInt32
    let version: UInt8
    let lookup: RuntimeLookup
    let modules: [RuntimeModule]
    let extrinsic: RuntimeExtrinsic
}
