import BigInt
import Foundation

/// Runtime lookup item. Consists of an id and runtime type.
public class RuntimeLookupItem: Codable {
    let id: BigUInt
    let type: RuntimeType
    
    init(id: BigUInt, type: RuntimeType) {
        self.id = id
        self.type = type
    }
}
