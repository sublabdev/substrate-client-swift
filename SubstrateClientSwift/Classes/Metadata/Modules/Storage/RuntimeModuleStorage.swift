import Foundation

/// Runtime module storage. Consists of a prefix and an array of module storage items
public struct RuntimeModuleStorage: Codable {
    let prefix: String
    let items: [RuntimeModuleStorageItem]
}
