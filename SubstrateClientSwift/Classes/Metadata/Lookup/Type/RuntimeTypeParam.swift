import BigInt
import Foundation

/// Runtime type parametr
public class RuntimeTypeParam: Codable {
    let name: String
    let type: BigUInt?
    
    init(name: String, type: BigUInt?) {
        self.name = name
        self.type = type
    }
}
