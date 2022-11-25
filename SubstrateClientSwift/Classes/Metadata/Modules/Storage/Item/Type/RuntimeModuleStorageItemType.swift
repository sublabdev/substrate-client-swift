import Foundation

enum RuntimeModuleStorageItemType: Codable {
    enum CodingKeys: Int, CodingKey {
        case plain
        case map
    }
    
    case plain(value: RuntimeModuleStorageItemTypePlain)
    case map(value: RuntimeModuleStorageItemTypeMap)
}
