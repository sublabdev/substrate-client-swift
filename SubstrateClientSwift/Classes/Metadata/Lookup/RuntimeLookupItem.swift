import BigInt
import Foundation

/// Runtime lookup item. Consists of an id and runtime type.
public class RuntimeLookupItem: Codable {
    public let id: BigUInt
    public let type: RuntimeType
    
    public init(id: BigUInt, type: RuntimeType) {
        self.id = id
        self.type = type
    }
}
