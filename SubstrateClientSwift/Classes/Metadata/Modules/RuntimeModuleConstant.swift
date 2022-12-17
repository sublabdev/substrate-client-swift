import BigInt
import Foundation

/// Runtime module constant
public class RuntimeModuleConstant: Codable {
    let name: String
    let type: BigUInt
    let valueBytes: [UInt8]
    let docs: [String]
    
    init(name: String, type: BigUInt, valueBytes: [UInt8], docs: [String]) {
        self.name = name
        self.type = type
        self.valueBytes = valueBytes
        self.docs = docs
    }
}
