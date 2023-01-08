import Foundation

class Payload: Encodable {
    var moduleName: String
    var callName: String
    
    init(moduleName: String, callName: String) {
        self.moduleName = moduleName
        self.callName = callName
    }
}
