import BigInt
import Foundation

/// Array runtime type
public class RuntimeTypeDefArray: Codable {
    let length: UInt32
    let type: BigUInt
    
    init(length: UInt32, type: BigUInt) {
        self.length = length
        self.type = type
    }
}
