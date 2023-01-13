import Foundation
import ScaleCodecSwift

/// Unsigned payload object. Subclass of `Payload`
class UnsignedPayload<T: Codable>: Payload {
    let module: RuntimeModule
    let callVariant: RuntimeTypeDefVariant.Variant
    let callValue: T
    
    override var moduleName: String {
        get {
            return module.name
        } set {
            super.moduleName = newValue
        }
    }
    
    override var callName: String {
        get {
            return callVariant.name
        } set {
            super.callName = newValue
        }
    }
    
    init(
        module: RuntimeModule,
        callVariant: RuntimeTypeDefVariant.Variant,
        callValue: T
    ) {
        self.module = module
        self.callVariant = callVariant
        self.callValue = callValue
        
        super.init(moduleName: module.name, callName: callVariant.name)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(module.index)
        try container.encode(callVariant.index)
        try container.encode(callValue)
    }
}
