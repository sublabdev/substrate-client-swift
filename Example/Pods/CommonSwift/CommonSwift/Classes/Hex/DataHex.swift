import Foundation

/// A Data converter to hex-encoded String
public class DataHex {
    private let data: Data
    
    /// Creates a Data converter to hex-encoded String
    /// - Parameters:
    ///     - data: The data that is encoded int hex String
    public init(data: Data) {
        self.data = data
    }
    
    /// Encodes Data into hex String
    /// - Parameters:
    ///     - includePrefix: A flag indicating whether the prefix should be included or not. The default value is `false`
    /// - Returns: A hex-encoded String
    public func encode(includePrefix: Bool = false) -> String {
        let encoded = data.map { String(format: "%02x", $0) }.joined()
        var prefix = ""
        
        if includePrefix {
            prefix = "0x"
        }
        
        return prefix + encoded
    }
}

extension Data {
    /// Data to hex-encoded String converter
    public var hex: DataHex {
        .init(data: self)
    }
    
    /// Intializes a Data object from hex-encoded String
    /// - Parameters:
    ///     - hex: A hex-encoded String
    public init?(hex: String) {
        guard hex.count.isMultiple(of: 2) else { return nil }
        
        var hex = hex
        if hex.hasPrefix("0x") {
            hex = .init(hex.suffix(hex.count - 2))
        }
        
        let chars = hex.map { $0 }
        let bytes = stride(from: 0, to: chars.count, by: 2)
            .map { String(chars[$0]) + String(chars[$0 + 1]) }
            .compactMap { UInt8($0, radix: 16) }
        
        guard hex.count / bytes.count == 2 else { return nil }
        self.init(bytes)
    }
}
