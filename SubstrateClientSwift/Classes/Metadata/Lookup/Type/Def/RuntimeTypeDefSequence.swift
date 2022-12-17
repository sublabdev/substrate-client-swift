import BigInt
import Foundation

/// Sequence runtime type
public class RuntimeTypeDefSequence: Codable {
    let type: BigUInt
    
    init(type: BigUInt) {
        self.type = type
    }
}
