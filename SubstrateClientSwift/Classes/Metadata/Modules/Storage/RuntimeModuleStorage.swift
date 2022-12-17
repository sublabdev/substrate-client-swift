import Foundation

/// Runtime module storage. Consists of a prefix and an array of module storage items
public class RuntimeModuleStorage: Codable {
    let prefix: String
    let items: [RuntimeModuleStorageItem]
    
    init(prefix: String, items: [RuntimeModuleStorageItem]) {
        self.prefix = prefix
        self.items = items
    }
}
