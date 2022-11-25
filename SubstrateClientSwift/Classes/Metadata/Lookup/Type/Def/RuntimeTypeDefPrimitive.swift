import Foundation

enum RuntimeTypeDefPrimitive: Codable {
    enum CodingKeys: Int, CodingKey {
        case bool
        case char
        case string
        case uint8
        case uint16
        case uint32
        case uint64
        case uint128
        case uint256
        case int8
        case int16
        case int32
        case int64
        case int128
        case int256
    }
    
    case bool
    case char
    case string
    case uint8
    case uint16
    case uint32
    case uint64
    case uint128
    case uint256
    case int8
    case int16
    case int32
    case int64
    case int128
    case int256
}
