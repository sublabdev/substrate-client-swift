import BigInt
import Foundation

/// Runtime module storage item of plain type
class RuntimeModuleStorageItemTypePlain: Codable {
    let type: BigUInt
    
    init(type: BigUInt) {
        self.type = type
    }
}
