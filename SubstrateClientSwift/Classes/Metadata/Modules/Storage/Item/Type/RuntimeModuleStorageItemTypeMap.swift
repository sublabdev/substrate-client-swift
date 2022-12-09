import BigInt
import Foundation

/// Runtime module storage item of map type
struct RuntimeModuleStorageItemTypeMap: Codable {
    let hasers: [RuntimeModuleStorageHasher]
    let key: BigUInt
    let type: BigUInt
}
