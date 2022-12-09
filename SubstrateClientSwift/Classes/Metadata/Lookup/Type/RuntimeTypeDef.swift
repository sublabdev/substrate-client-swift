import Foundation

/// Runtime type definition
public enum RuntimeTypeDef: Codable {
    enum CodingKeys: Int, CodingKey {
        case composite
        case variant
        case sequence
        case array
        case tuple
        case primitive
        case compact
        case bitSequence
    }
    
    case composite(RuntimeTypeDefComposite)
    case variant(RuntimeTypeDefVariant)
    case sequence(RuntimeTypeDefSequence)
    case array(RuntimeTypeDefArray)
    case tuple(RuntimeTypeDefTuple)
    case primitive(RuntimeTypeDefPrimitive)
    case compact(RuntimeTypeDefCompact)
    case bitSequence(RuntimeTypeDefBitSequence)
}
