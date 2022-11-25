import Foundation

struct RuntimeModuleStorageItem: Codable {
    let name: String
    let modifier: RuntimeModuleStorageItemModifier
    let type: RuntimeModuleStorageItemType
    var fallbackBytes: [UInt8]
    let docs: [String]
}
