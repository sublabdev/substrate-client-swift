import BigInt
import Foundation

/// Runtime Metadata
public class RuntimeMetadata: Codable {
    let magicNumber: UInt32
    let version: UInt8
    let lookup: RuntimeLookup
    let modules: [RuntimeModule]
    let extrinsic: RuntimeExtrinsic
}
