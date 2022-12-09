import BigInt
import Foundation

/// Runtime lookup item. Consists of an id and runtime type.
public struct RuntimeLookupItem: Codable {
    let id: BigUInt
    let type: RuntimeType
}
