import BigInt
import Foundation

/// Runtime module storage item of map type
class RuntimeModuleStorageItemTypeMap: Codable {
    let hasers: [RuntimeModuleStorageHasher]
    let key: BigUInt
    let type: BigUInt
    
    init(hasers: [RuntimeModuleStorageHasher], key: BigUInt, type: BigUInt) {
        self.hasers = hasers
        self.key = key
        self.type = type
    }
}
