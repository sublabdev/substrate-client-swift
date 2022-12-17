import Foundation

/// Runtime type
public class RuntimeType: Codable {
    let path: [String]
    let params: [RuntimeTypeParam]
    let def: RuntimeTypeDef
    let docs: [String]
    
    init(path: [String], params: [RuntimeTypeParam], def: RuntimeTypeDef, docs: [String]) {
        self.path = path
        self.params = params
        self.def = def
        self.docs = docs
    }
}
