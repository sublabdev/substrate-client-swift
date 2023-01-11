import BigInt
import Foundation

/// Runtime module storage item of plain type
public class RuntimeModuleStorageItemTypePlain: Codable {
    public let type: BigUInt
    
    public init(type: BigUInt) {
        self.type = type
    }
}
