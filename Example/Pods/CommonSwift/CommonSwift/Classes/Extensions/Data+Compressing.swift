import Foundation

extension Data {
    public var removingZeroesAtEnd: Data {
        guard let offset = lastIndex(where: { $0 > 0 }) else {
            return Data([0])
        }
    
        return self[0...offset]
    }
    
    public func fillingZeroesAtEnd(byteWidth: Int) -> Data {
        guard count != byteWidth else { return self }
        
        var data = self
        for _ in 0..<(byteWidth - count) {
            data.append(0)
        }
        
        return data
    }
}
