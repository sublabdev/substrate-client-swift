import Foundation

/// A hex-encoded String to Data converter object
public class StringHex {
    private let string: String
    
    /// Creates a hex-encoded String to Data converter object
    /// - Parameters:
    ///     - string: Hex-encoded String to convert into Data
    public init(string: String) {
        self.string = string
    }
    
    /// Converts hex-encoded String into Data
    /// - Returns: Optional Data converted from hex-encoded String
    public func decode() -> Data? {
        let hexStr = string.dropFirst(string.hasPrefix("0x") ? 2 : 0)
        
        guard hexStr.count % 2 == 0 else {
            return nil
        }
        
        var newData = Data(capacity: hexStr.count/2)
        
        var indexIsEven = true
        for i in hexStr.indices {
            if indexIsEven {
                let byteRange = i...hexStr.index(after: i)
                guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
                newData.append(byte)
            }
            indexIsEven.toggle()
        }
        return newData
    }
}

public extension String {
    /// Hex-encoded String to Data converter
    var hex: StringHex {
        .init(string: self)
    }
}
