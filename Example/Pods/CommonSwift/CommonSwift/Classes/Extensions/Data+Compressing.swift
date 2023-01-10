import Foundation

extension Data {
    
    /// The `Data` with zeroes removed at the end if needed
    public var removingZeroesAtEnd: Data {
        guard let offset = lastIndex(where: { $0 > 0 }) else {
            return Data([0])
        }
    
        return self[0...offset]
    }
    
    /// Fills zeroes at the end if needed
    /// - Parameters:
    ///     - byteWidth: Describes the width of byte which is used to calculate the number of zeroes to add
    /// - Returns: `Data` with zeroes filled in
    public func fillingZeroesAtEnd(byteWidth: Int) -> Data {
        guard count != byteWidth else { return self }
        
        var data = self
        for _ in 0..<(byteWidth - count) {
            data.append(0)
        }
        
        return data
    }
}
