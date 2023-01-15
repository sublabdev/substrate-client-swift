/**
 *
 * Copyright 2023 SUBSTRATE LABORATORY LLC <info@sublab.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

import EncryptingSwift
import Foundation
import HashingSwift
import ScaleCodecSwift

private struct RuntimeCall {
    let module: RuntimeModule
    let variant: RuntimeTypeDefVariant.Variant
}

public protocol SubstrateExtrinsics: AnyObject {
    /// Makes an unsigned payload
    /// - Parameters:
    ///     - moduleName: A runtime module name used to find the call
    ///     - callName: Name of a call
    ///     - callValue: A generic call value
    /// - Returns: An unsigned payload
    func makeUnsigned<T: Codable>(
        moduleName: String,
        callName: String,
        callValue: T
    ) async throws -> Payload?
    
    /// Makes an unsigned payload from a call
    /// - Parameters:
    ///     - call: A generic call
    ///- Returns: An unsigned payload
    func makeUnsigned<T: Codable>(call: Call<T>) async throws -> Payload?
    
    /// Makes a signed payload
    /// - Parameters:
    ///     - moduleName: Module name
    ///     - callName: Call name
    ///     - callValue: Generic call value
    ///     - tip: Tip conforming to `DynamicType`
    ///     - signatureEngine: Signature engine
    /// - Returns: An optional signed payload
    func makeSigned<T: Codable>(
        moduleName: String,
        callName: String,
        callValue: T,
        tip: Balance,
        accountId: AccountId,
        signatureEngine: SignatureEngine
    ) async throws -> Payload?
    
    /// Makes a signed payload
    /// - Parameters:
    ///     - call: A generic call
    ///     - tip: Tip conforming to `DynamicType`
    ///     - accountId: An account id
    ///     - signatureEngine: Signature engine
    /// - Returns: An optional signed payload
    func makeSigned<T: Codable>(
        call: Call<T>,
        tip: Balance,
        accountId: AccountId,
        signatureEngine: SignatureEngine
    ) async throws -> Payload?
    
    /// Makes a signed payload
    /// - Parameters:
    ///     - call: A generic call
    ///     - tip: Tip conforming to `DynamicType`
    ///     - keyPair: A keypair with private and public keys
    /// - Returns: An optional signed payload
    func makeSigned<T: Codable>(
        call: Call<T>,
        tip: Balance,
        keyPair: KeyPair
    ) async throws -> Payload?
}

protocol InternalSubstrateExtrinsics: SubstrateExtrinsics {
    var runtimeMetadataProvider: RuntimeMetadataProvider? { get set }
}

/// Substrate extrinsics service
public class SubstrateExtrinsicsService: InternalSubstrateExtrinsics {
    weak var runtimeMetadataProvider: RuntimeMetadataProvider?
    private weak var modules: ModuleRpcProvider?
    private weak var codec: ScaleCoder?
    private weak var lookup: SubstrateLookup?
    private let namingPolicy: SubstrateClientNamingPolicy
    
    init(
        modules: ModuleRpcProvider,
        codec: ScaleCoder,
        lookup: SubstrateLookup,
        namingPolicy: SubstrateClientNamingPolicy
    ) {
        self.modules = modules
        self.codec = codec
        self.lookup = lookup
        self.namingPolicy = namingPolicy
    }
}

// MARK: - Finding call

extension SubstrateExtrinsicsService {
    /// Finds a call for a given variant
    /// - Parameters:
    ///     - variant: A variant runtime type used to find the call
    ///     - callName: The name by which the call should be found
    /// - Returns: The call with a given name for a variant
    private func findCall(variant: RuntimeTypeDefVariant, callName: String) ->  RuntimeTypeDefVariant.Variant? {
        variant.variants.first(where: { namingPolicy.equals(callName, $0.name) })
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
    private func findCall(module: RuntimeModule, callName: String) async throws -> RuntimeCall? {
        guard let callIndex = module.callIndex else { return nil }
        
        let runtimeItem = try await lookup?.findRuntimeItem(index: callIndex)
        
        guard let variant = findCall(typeDef: runtimeItem?.def, callName: callName) else {
            return nil
        }
        
        return RuntimeCall(module: module, variant: variant)
    }
    
    /// Finds a call for a given runtime module name
    /// - Parameters:
    ///     - moduleName: A runtime module name used to find the call
    ///     - callName: The name by which the call should be found
    /// - Returns: A runtime call with a runtime module and variant
    private func findCall(moduleName: String, callName: String) async throws -> RuntimeCall? {
        guard let runtimeModule = try await lookup?.module(name: moduleName) else { return nil }
        return try await findCall(module: runtimeModule, callName: callName)
    }
}

// MARK: - Payload

extension SubstrateExtrinsicsService {
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
    ) async throws -> UnsignedPayload<T>? {
        guard let call = try await findCall(moduleName: moduleName, callName: callName) else { return nil }
        
        return UnsignedPayload(
            codec: codec,
            module: call.module,
            callVariant: call.variant,
            callValue: callValue
        )
    }
}

// MARK: - Unsigned

extension SubstrateExtrinsicsService {
    public func makeUnsigned<T: Codable>(
        moduleName: String,
        callName: String,
        callValue: T
    ) async throws -> Payload? {
        try await makePayload(moduleName: moduleName, callName: callName, callValue: callValue)
    }
    
    public func makeUnsigned<T: Codable>(call: Call<T>) async throws -> Payload? {
        try await makeUnsigned(
            moduleName: call.moduleName,
            callName: call.name,
            callValue: call.value
        )
    }
}

// MARK: - Signed

extension SubstrateExtrinsicsService {
    public func makeSigned<T: Codable>(
        moduleName: String,
        callName: String,
        callValue: T,
        tip: Balance,
        accountId: AccountId,
        signatureEngine: SignatureEngine
    ) async throws -> Payload? {
        SignedPayload(
            runtimeMetadata: try await runtimeMetadataProvider?.runtimeMetadata() as RuntimeMetadata?,
            codec: codec,
            payload: try await makePayload(moduleName: moduleName, callName: callName, callValue: callValue),
            runtimeVersion: try await modules?.systemRpc.runtimeVersion() as RuntimeVersion?,
            genesisHash: try await modules?.chainRpc.blockHash(number: 0) as String?,
            accountId: accountId,
            nonce: try await modules?.systemRpc.account(accountId: accountId)?.nonce,
            tip: tip,
            signatureEngine: signatureEngine
        )
    }
    
    public func makeSigned<T: Codable>(
        call: Call<T>,
        tip: Balance,
        accountId: AccountId,
        signatureEngine: SignatureEngine
    ) async throws -> Payload? {
        try await makeSigned(
            moduleName: call.moduleName,
            callName: call.name,
            callValue: call.value,
            tip: tip,
            accountId: accountId,
            signatureEngine: signatureEngine
        )
    }
    
    public func makeSigned<T: Codable>(
        call: Call<T>,
        tip: Balance,
        keyPair: KeyPair
    ) async throws -> Payload? {
        try await makeSigned(
            call: call,
            tip: tip,
            accountId: keyPair.publicKey.ss58.accountId(),
            signatureEngine: keyPair.signatureEngine(for: keyPair.privateKey)
        )
    }
    
    /// Method for extrinsics tests which sets `nonce` as '0', otherwise error is posted
    func makeSigned<T: Codable>(
        moduleName: String,
        callName: String,
        callValue: T,
        tip: Balance,
        accountId: AccountId,
        nonce: Index,
        signatureEngine: SignatureEngine
    ) async throws -> Payload? {
        SignedPayload(
            runtimeMetadata: try await runtimeMetadataProvider?.runtimeMetadata() as RuntimeMetadata?,
            codec: codec,
            payload: try await makePayload(moduleName: moduleName, callName: callName, callValue: callValue),
            runtimeVersion: try await modules?.systemRpc.runtimeVersion() as RuntimeVersion?,
            genesisHash: try await modules?.chainRpc.blockHash(number: 0) as String?,
            accountId: accountId,
            nonce: nonce,
            tip: tip,
            signatureEngine: signatureEngine
        )
    }
}
