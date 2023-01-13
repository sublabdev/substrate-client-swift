import BigInt
import Foundation

/// Runtime type parameter
public class RuntimeTypeParam: Codable {
    public let name: String
    public let type: BigUInt?
    
    public init(name: String, type: BigUInt?) {
        self.name = name
        self.type = type
    }
}
