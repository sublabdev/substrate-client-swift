import BigInt
import Foundation

struct RuntimeLookup: Codable {
    let items: [RuntimeLookupItem]
    
    private var itemsByIndices: [(BigUInt, RuntimeLookupItem)] {
        items.enumerated().map { (BigUInt($0), $1) }
    }
    
    func findItemByIndex(_ index: BigUInt) -> RuntimeLookupItem? {
        itemsByIndices.first { $0.0 == index }?.1
    }
}
