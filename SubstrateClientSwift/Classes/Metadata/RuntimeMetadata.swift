import BigInt
import Foundation

/// Runtime Metadata
public final class RuntimeMetadata: Codable {
    public let magicNumber: UInt32
    public let version: UInt8
    public let lookup: RuntimeLookup
    public let modules: [RuntimeModule]
    public let extrinsic: RuntimeExtrinsic
}
