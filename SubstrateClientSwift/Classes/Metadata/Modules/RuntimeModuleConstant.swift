import BigInt
import Foundation

/// Runtime module constant
public class RuntimeModuleConstant: Codable {
    public let name: String
    public let type: BigUInt
    public let valueBytes: [UInt8]
    public let docs: [String]
    
    public init(name: String, type: BigUInt, valueBytes: [UInt8], docs: [String]) {
        self.name = name
        self.type = type
        self.valueBytes = valueBytes
        self.docs = docs
    }
}
