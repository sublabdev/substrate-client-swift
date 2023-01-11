import Foundation
import ScaleCodecSwift

public protocol DynamicType: Codable {
    static var lookupIndex: Int { get }
    
    init(data: Data)
    func toData() -> Data
}

extension DynamicType {
    public func encode(to encoder: Encoder) throws {
        fatalError("shouldn't be called")
    }
    
    public init(from decoder: Decoder) throws {
        fatalError("shouldn't be called")
    }
}
