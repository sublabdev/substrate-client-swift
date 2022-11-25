import Foundation

enum RuntimeModuleStorageItemModifier: Codable {
    enum CodingKeys: Int, CodingKey {
        case optional
        case defaultOne
    }
    
    case optional
    case defaultOne
}
