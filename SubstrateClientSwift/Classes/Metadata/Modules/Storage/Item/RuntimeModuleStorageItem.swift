import Foundation

/// Runtime module storage item
public class RuntimeModuleStorageItem: Codable {
    let name: String
    let modifier: RuntimeModuleStorageItemModifier
    let type: RuntimeModuleStorageItemType
    var fallbackBytes: [UInt8]
    let docs: [String]
    
    init(
        name: String,
        modifier: RuntimeModuleStorageItemModifier,
        type: RuntimeModuleStorageItemType,
        fallbackBytes: [UInt8], docs: [String]
    ) {
        self.name = name
        self.modifier = modifier
        self.type = type
        self.fallbackBytes = fallbackBytes
        self.docs = docs
    }
}
