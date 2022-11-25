import Foundation

struct RuntimeTypeDefVariant: Codable {
    let variants: [Variant]
    
    struct Variant: Codable {
        let name: String
        let fields: [RuntimeTypeDefField]
        let index: UInt8
        let docs: [String]
    }
}
