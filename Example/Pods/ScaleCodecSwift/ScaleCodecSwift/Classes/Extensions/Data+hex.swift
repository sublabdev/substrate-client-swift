import Foundation

extension Data {
    init?(hex: String) {
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
    
    func hexString(prefix: Bool = true) -> String {
        (prefix ? "0x" : "") + map { String(format: "%02hhx", $0) }.joined()
    }
}
