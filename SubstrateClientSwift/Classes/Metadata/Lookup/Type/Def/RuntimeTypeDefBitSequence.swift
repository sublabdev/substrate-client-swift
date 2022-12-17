import BigInt
import Foundation

/// Bit sequence runtime type
public class RuntimeTypeDefBitSequence: Codable {
    let store: BigUInt
    let order: BigUInt
    
    init(store: BigUInt, order: BigUInt) {
        self.store = store
        self.order = order
    }
}
