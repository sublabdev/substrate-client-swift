import Foundation

/// Runtime module storage item modifier. Can be either `.optional` or `.defaultOne`
public enum RuntimeModuleStorageItemModifier: Codable {
    enum CodingKeys: Int, CodingKey {
        case optional
        case defaultOne
    }
    
    case optional
    case defaultOne
}
