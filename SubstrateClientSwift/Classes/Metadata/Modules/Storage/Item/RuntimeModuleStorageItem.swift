import Foundation

/// Runtime module storage item
public class RuntimeModuleStorageItem: Codable {
    public let name: String
    public let modifier: RuntimeModuleStorageItemModifier
    public let type: RuntimeModuleStorageItemType
    public var fallbackBytes: [UInt8]
    public let docs: [String]
    
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
