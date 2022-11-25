import Foundation

struct RuntimeType: Codable {
    let path: [String]
    let params: [RuntimeTypeParam]
    let def: RuntimeTypeDef
    let docs: [String]
}
