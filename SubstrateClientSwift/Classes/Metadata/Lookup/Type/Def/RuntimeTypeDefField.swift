import BigInt
import Foundation

/// Runtime type field
class RuntimeTypeDefField: Codable {
    let name: String?
    let type: BigUInt
    let typeName: String?
    let docs: [String]
    
    init(name: String?, type: BigUInt, typeName: String?, docs: [String]) {
        self.name = name
        self.type = type
        self.typeName = typeName
        self.docs = docs
    }
}
