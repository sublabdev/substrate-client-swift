import Foundation
import ScaleCodecSwift

/// Unsigned payload object. Subclass of `Payload`
final class UnsignedPayload<T: Codable>: Payload {
    private weak var codec: ScaleCoder?
    fileprivate let module: RuntimeModule
    fileprivate let callVariant: RuntimeTypeDefVariant.Variant
    fileprivate let callValue: T
    
    var moduleName: String { module.name }
    var callName: String { callVariant.name }
    
    init(
        codec: ScaleCoder?,
        module: RuntimeModule,
        callVariant: RuntimeTypeDefVariant.Variant,
        callValue: T
    ) {
        self.codec = codec
        self.module = module
        self.callVariant = callVariant
        self.callValue = callValue
    }
    
    func toData() throws -> Data? {
        try codec?.transaction()
            .appendUnsignedPayload(self)
            .commit()
    }
}

extension ScaleCodecTransaction {
    func appendUnsignedPayload<T: Codable>(_ unsignedPayload: UnsignedPayload<T>) throws -> Self {
        try append(unsignedPayload.module.index)
            .append(unsignedPayload.callVariant.index)
            .append(unsignedPayload.callValue)
    }
}
