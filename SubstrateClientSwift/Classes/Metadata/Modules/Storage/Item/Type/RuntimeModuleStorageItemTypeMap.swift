import BigInt
import Foundation

/// Runtime module storage item of map type
public class RuntimeModuleStorageItemTypeMap: Codable {
    public let hasers: [RuntimeModuleStorageHasher]
    public let key: BigUInt
    public let type: BigUInt
    
    init(hasers: [RuntimeModuleStorageHasher], key: BigUInt, type: BigUInt) {
        self.hasers = hasers
        self.key = key
        self.type = type
    }
}
