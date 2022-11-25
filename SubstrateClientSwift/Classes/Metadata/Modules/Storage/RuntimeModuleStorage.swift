import Foundation

struct RuntimeModuleStorage: Codable {
    let prefix: String
    let items: [RuntimeModuleStorageItem]
}
