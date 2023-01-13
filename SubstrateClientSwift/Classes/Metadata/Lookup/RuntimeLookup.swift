import BigInt
import CommonSwift
import Foundation

/// Runtime lookup. Holds an array of lookup items
public class RuntimeLookup: Codable {
    public let items: [RuntimeLookupItem]

    private var itemsByIndices: [(BigUInt, RuntimeType)] {
        items.enumerated().map { (BigUInt($0), $1.type) }
    }
    
    public init(items: [RuntimeLookupItem]) {
        self.items = items
    }
    
    /// Finds a lookup item by an index
    /// - Parameters:
    ///     - index: Index to find a lookup item
    /// - Returns: A lookup item for a specific index
    public func findItem(by index: BigUInt) -> RuntimeType? {
        itemsByIndices.first { $0.0 == index }?.1
    }
    
    /// Returns a runtime type based on an index
    /// - Parameters:
    ///     - index: Index to find a runtime type
    /// - Returns: A runtime type for the provided index
    public func findItemByIndex(_ index: Int) -> RuntimeType? {
        findItem(by: BigUInt(index))
    }
}
