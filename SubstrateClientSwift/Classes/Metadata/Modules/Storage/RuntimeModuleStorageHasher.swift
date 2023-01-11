import Foundation

/// Runtime module storage hasher types
public enum RuntimeModuleStorageHasher: Codable {
    enum CodingKeys: Int, CodingKey {
        case blake128
        case blake256
        case blake128Concat
        case twox128
        case twox256
        case twox64Concat
        case identity
    }
    
    case blake128
    case blake256
    case blake128Concat
    case twox128
    case twox256
    case twox64Concat
    case identity
}
