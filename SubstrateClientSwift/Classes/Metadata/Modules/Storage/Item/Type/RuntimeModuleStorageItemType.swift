import Foundation

/// Runtime module storage item type. Can be either `.plain` or `.map`
enum RuntimeModuleStorageItemType: Codable {
    enum CodingKeys: Int, CodingKey {
        case plain
        case map
    }
    
    case plain(value: RuntimeModuleStorageItemTypePlain)
    case map(value: RuntimeModuleStorageItemTypeMap)
}
