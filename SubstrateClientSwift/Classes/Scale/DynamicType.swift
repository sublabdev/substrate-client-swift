import Foundation
import ScaleCodecSwift

/// Dynamic type with a lookup index. Conforms to `Codable`
public protocol DynamicType: Codable {
    static var lookupIndex: Int { get }
    
    init(data: Data)
    func toData() -> Data
}
