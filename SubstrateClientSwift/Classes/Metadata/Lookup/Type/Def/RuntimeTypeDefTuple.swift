import BigInt
import Foundation

/// Tuple runtime type
public class RuntimeTypeDefTuple: Codable {
    let types: [BigUInt]
    
    init(types: [BigUInt]) {
        self.types = types
    }
}
