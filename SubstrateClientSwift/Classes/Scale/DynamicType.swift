import Foundation
import ScaleCodecSwift

public protocol DynamicType: Codable {
    static var lookupIndex: Int { get }
    
    init(data: Data)
    func toData() -> Data
}
