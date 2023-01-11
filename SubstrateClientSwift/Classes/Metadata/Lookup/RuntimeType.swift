import Foundation

/// Runtime type
public class RuntimeType: Codable {
    public let path: [String]
    public let params: [RuntimeTypeParam]
    public let def: RuntimeTypeDef
    public let docs: [String]
    
    public init(path: [String], params: [RuntimeTypeParam], def: RuntimeTypeDef, docs: [String]) {
        self.path = path
        self.params = params
        self.def = def
        self.docs = docs
    }
}
