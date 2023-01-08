import BigInt
import CommonSwift
import Foundation

/// Runtime lookup. Holds an array of lookup items
public class RuntimeLookup: Codable {
    let items: [RuntimeLookupItem]

    private var itemsByIndices: [(BigUInt, RuntimeLookupItem)] {
        items.enumerated().map { (BigUInt($0), $1) }
    }
    
    init(items: [RuntimeLookupItem]) {
        self.items = items
    }
    
    /// Finds a lookup item by an index
    /// - Parameters:
    ///     - index: Index to find a lookup item
    /// - Returns: A lookup item for a specific index
    func findItemByIndex(_ index: BigUInt) -> RuntimeLookupItem? {
        itemsByIndices.first { $0.0 == index }?.1
    }
    
    func findItemByIndex(_ index: Int) -> RuntimeLookupItem? {
        findItemByIndex(index)
    }
}
