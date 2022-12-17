import BigInt
import Foundation

/// Compact runtime type
public class RuntimeTypeDefCompact: Codable {
    let type: BigUInt
    
    init(type: BigUInt) {
        self.type = type
    }
}
