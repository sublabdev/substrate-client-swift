import Foundation

/// Variant runtime type
public class RuntimeTypeDefVariant: Codable {
    let variants: [Variant]
    
    init(variants: [Variant]) {
        self.variants = variants
    }
    
    struct Variant: Codable {
        let name: String
        let fields: [RuntimeTypeDefField]
        let index: UInt8
        let docs: [String]
    }
}
