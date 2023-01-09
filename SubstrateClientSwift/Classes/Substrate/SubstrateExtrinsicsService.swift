import Foundation
import ScaleCodecSwift

private class RuntimeCall {
    let module: RuntimeModule
    let variant: RuntimeTypeDefVariant.Variant
    
    init(module: RuntimeModule, variant: RuntimeTypeDefVariant.Variant) {
        self.module = module
        self.variant = variant
    }
}

/// Substrate extrinsics service
class SubstrateExtrinsicsService {
    weak var runtimeMetadata: RuntimeMetadata?
    let codec: ScaleCoder
    let lookup: SubstrateLookupService
    let namingPolicy: SubstrateClientNamingPolicy
    let clientQueue: DispatchQueue
    
    init(
        codec: ScaleCoder,
        lookup: SubstrateLookupService,
        namingPolicy: SubstrateClientNamingPolicy,
        clientQueue: DispatchQueue
    ) {
        self.codec = codec
        self.lookup = lookup
        self.namingPolicy = namingPolicy
        self.runtimeMetadata = lookup.runtimeMetadata
        self.clientQueue = clientQueue
    }
    
    /// Makes an unsigned payload
    /// - Parameters:
    ///     - moduleName: A runtime module name used to find the call
    ///     - callName: Name of a call
    ///     - callValue: A generic call value
    ///     - completion: Completion with an unsigned payload
    func makeUnsigned<T: Codable>(
        moduleName: String,
        callName: String,
        callValue: T,
        completion: @escaping (Payload?) -> Void
    ) {
        let payload = makePayload(moduleName: moduleName, callName: callName, callValue: callValue)
        
        clientQueue.async {
            completion(payload)
        }
    }
    
    /// Makes an unsigned payload from a call
    /// - Parameters:
    ///     - call: A generic call
    ///     - completion: Completion with an unsigned payload
    func makeUnsigned<T: Codable>(call: Call<T>, completion: @escaping (Payload?) -> Void) {
        makeUnsigned(
            moduleName: call.moduleName,
            callName: call.name,
            callValue: call.value,
            completion: completion
        )
    }
    
    // TODO: Add logic for SignedPayload
    
    // MARK: - Private
    /// Finds a call for a given variant
    /// - Parameters:
    ///     - variant: A variant runtime type used to find the call
    ///     - callName: The name by which the call should be found
    /// - Returns: The call with a given name for a variant
    private func findCall(variant: RuntimeTypeDefVariant, callName: String) ->  RuntimeTypeDefVariant.Variant? {
        variant.variants.first(where: { namingPolicy.equals(lhs: callName, rhs: $0.name) })
    }
    
    /// Finds a call for a given runtime type defenition
    /// - Parameters:
    ///     - typeDef: A runtime type defenition used to find the call
    ///     - callName: The name by which the call should be found
    /// - Returns: The call with a given name for a runtime type defenition
    private func findCall(typeDef: RuntimeTypeDef?, callName: String) -> RuntimeTypeDefVariant.Variant? {
        if case .variant(let variant) = typeDef {
            return findCall(variant: variant, callName: callName)
        }
        
        return nil
    }
    
    /// Finds a runtime call for a given runtime module
    /// - Parameters:
    ///     - module: A runtime module used to find the call
    ///     - callName: The name by which the call should be found
    /// - Returns: A runtime call with a runtime module and variant
    private func findCall(module: RuntimeModule, callName: String) -> RuntimeCall? {
        guard let callIndex = module.callIndex else { return nil }
        
        let runtimeItem = lookup.findRuntimeItem(index: callIndex)
        
        guard let variant = findCall(typeDef: runtimeItem?.type.def, callName: callName) else {
            return nil
        }
        
        return RuntimeCall(module: module, variant: variant)
    }
    
    /// Finds a call for a given runtime module name
    /// - Parameters:
    ///     - moduleName: A runtime module name used to find the call
    ///     - callName: The name by which the call should be found
    /// - Returns: A runtime call with a runtime module and variant
    private func findCall(moduleName: String, callName: String) -> RuntimeCall? {
        guard let runtimeModule = lookup.findModule(name: moduleName) else { return nil }
        
        return findCall(module: runtimeModule, callName: callName)
    }
    
    /// Makes an unsigned payload
    /// - Parameters:
    ///     - moduleName: A runtime module name used to find the call
    ///     - callName: Name of a call
    ///     - callValue: A generic call value
    /// - Returns: An unsigned payload
    private func makePayload<T: Codable>(
        moduleName: String,
        callName: String,
        callValue: T
    ) -> Payload? {
        guard let call = findCall(moduleName: moduleName, callName: callName) else { return nil }
        
        return UnsignedPayload(
            module: call.module,
            callVariant: call.variant,
            callValue: callValue
        )
    }
}
