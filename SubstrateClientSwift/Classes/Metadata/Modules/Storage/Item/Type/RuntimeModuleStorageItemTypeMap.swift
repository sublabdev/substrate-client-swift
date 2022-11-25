import BigInt
import Foundation

struct RuntimeModuleStorageItemTypeMap: Codable {
    let hasers: [RuntimeModuleStorageHasher]
    let key: BigUInt
    let type: BigUInt
}
