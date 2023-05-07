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

/// Signed payload. A subclass of `Payload`
final class SignedPayload<T: Codable>: Payload {
    fileprivate let runtimeMetadata: RuntimeMetadata?
    private weak var codec: ScaleCoder?
    private let payload: UnsignedPayload<T>?
    fileprivate let runtimeVersion: RuntimeVersion?
    fileprivate let genesisHash: String?
    fileprivate let era: Era
    fileprivate let blockHash: String?
    fileprivate let accountId: AccountId
    fileprivate let nonce: Index?
    fileprivate let tip: Balance
    fileprivate let signatureEngine: SignatureEngine
    
    var moduleName: String? { payload?.moduleName }
    var callName: String? { payload?.callName }
    
    init(
        runtimeMetadata: RuntimeMetadata?,
        codec: ScaleCoder?,
        payload: UnsignedPayload<T>?,
        runtimeVersion: RuntimeVersion?,
        genesisHash: String?,
        era: Era = .immortal,
        blockHash: String? = nil,
        accountId: AccountId,
        nonce: Index?,
        tip: Balance,
        signatureEngine: SignatureEngine
    ) {
        self.runtimeMetadata = runtimeMetadata
        self.codec = codec
        self.payload = payload
        self.runtimeVersion = runtimeVersion
        self.genesisHash = genesisHash
        self.era = era
        self.blockHash = blockHash ?? genesisHash
        self.accountId = accountId
        self.nonce = nonce
        self.tip = tip
        self.signatureEngine = signatureEngine
    }
}

// MARK: - Extrinsic composition

extension SignedPayload {
    private func makeExtrinsic() throws -> Data {
        guard let payloadData = try payload?.toData().asScaleEncoded() else {
            throw ExtrinsicError.noPayload
        }
        guard let extrinsicVersion = runtimeMetadata?.extrinsic.version else { throw ExtrinsicError.noRuntimeMetadata }
        guard let codec = codec else { throw ExtrinsicError.noCodec }
        
        return try codec.transaction()
            .append(0b10000000 + extrinsicVersion)
            .appendAccountId(from: self)
            .appendSignature(from: self)
            .appendExtra(from: self)
            .append(payloadData)
            .commit()
    }
    
    func toData() throws -> Data {
        guard let codec = codec else { throw ExtrinsicError.noCodec }
        return try codec.encoder.encode(makeExtrinsic())
    }
}

// MARK: - Signing

extension SignedPayload {
    private func signingPayload() throws -> Data {
        guard let payload = payload else { throw ExtrinsicError.noPayload }
        guard let codec = codec else { throw ExtrinsicError.noCodec }
        
        return try codec.transaction()
            .appendUnsignedPayload(payload)
            .appendExtra(from: self)
            .appendAdditional(from: self)
            .commit()
    }
    
    /// Signs the payload
    /// - Returns: A signed payload
    func sign() throws -> Data {
        var signingPayload = try signingPayload()
        if signingPayload.count > 256 /* move to constants */ {
            signingPayload = try signingPayload.hashing.blake2b_256()
        }
        
        return try signatureEngine.sign(message: signingPayload)
    }
}

// MARK: - Resolving Signature's RuntimeTypeDef from RuntimeMetadata

extension RuntimeMetadata {
    fileprivate func findSignatureTypeDef(name: String) throws -> RuntimeTypeDef {
        let extrinsicTypeIndex = extrinsic.type
        guard let extrinsicType = lookup.findItem(by: extrinsicTypeIndex) else {
            throw ExtrinsicError.lookupFailure
        }
        
        guard let lookupTypeIndex = extrinsicType.params.first(where: { $0.name == name })?.type else {
            throw ExtrinsicError.lookupFailure
        }
        
        guard let signatureTypeDef = lookup.findItem(by: lookupTypeIndex)?.def else {
            throw ExtrinsicError.lookupFailure
        }
        
        return signatureTypeDef
    }
}

// MARK: - `AccountId` serialization

extension ScaleCodecTransaction {
    fileprivate func appendAccountId<T: Codable>(from signedPayload: SignedPayload<T>) throws -> Self {
        guard let runtimeMetadata = signedPayload.runtimeMetadata else { throw ExtrinsicError.noRuntimeMetadata }
        let addressTypeDef = try runtimeMetadata.findSignatureTypeDef(name: "Address")
        switch addressTypeDef {
        case .variant(let runtimeTypeDefVariant):
            let addressVariants = runtimeTypeDefVariant.variants
            guard let addressIdTypeIndex = addressVariants.first(where: { $0.name == "Id" })?.index else {
                throw ExtrinsicError.lookupFailure
            }
            
            try append(addressIdTypeIndex)
            // Ignore size, inject directly
            try append(signedPayload.accountId.asScaleEncoded())
        default:
            throw ExtrinsicError.lookupFailure
        }
        
        return self
    }
}

// MARK: - `Signature` serialization

extension ScaleCodecTransaction {
    fileprivate func appendSignature<T: Codable>(from signedPayload: SignedPayload<T>) throws -> Self {
        guard let runtimeMetadata = signedPayload.runtimeMetadata else { throw ExtrinsicError.noRuntimeMetadata }
        let signatureTypeDef = try runtimeMetadata.findSignatureTypeDef(name: "Signature")
        switch signatureTypeDef {
        case .variant(let runtimeTypeDefVariant):
            let signatureVariants = runtimeTypeDefVariant.variants
            guard let signatureTypeIndex = signatureVariants.first(where: { $0.name.lowercased() == signedPayload.signatureEngine.name.lowercased() })?.index else {
                throw ExtrinsicError.lookupFailure
            }
            
            try append(signatureTypeIndex)
            // Ignore size, inject directly
            try append(try signedPayload.sign().asScaleEncoded())
        default:
            throw ExtrinsicError.lookupFailure
        }
        
        return self
    }
}

// MARK: - `Extra` serialization

extension ScaleCodecTransaction {
    fileprivate func appendExtra<T: Codable>(from signedPayload: SignedPayload<T>) throws -> Self {
        guard let runtimeMetadata = signedPayload.runtimeMetadata else { throw ExtrinsicError.noRuntimeMetadata }
        for ext in runtimeMetadata.extrinsic.signedExtensions {
            switch ext.identifier {
            case "CheckMortality":
                try append(signedPayload.era)
            case "CheckNonce":
                guard let nonce = signedPayload.nonce else { throw ExtrinsicError.noNonce }
                try append(nonce.value)
            case "ChargeTransactionPayment":
                try append(signedPayload.tip.value)
            default: break
            }
        }
        
        return self
    }
}

// MARK: - `Additional` serialization

extension ScaleCodecTransaction {
    fileprivate func appendAdditional<T: Codable>(from signedPayload: SignedPayload<T>) throws -> Self {
        guard let runtimeMetadata = signedPayload.runtimeMetadata else { throw ExtrinsicError.noRuntimeMetadata }
        
        for ext in runtimeMetadata.extrinsic.signedExtensions {
            switch ext.identifier {
            case "CheckGenesis":
                guard let genesisHash = signedPayload.genesisHash else { throw ExtrinsicError.noGenesisHash }
                try append(try genesisHash.hex.decode().asScaleEncoded())
            case "CheckMortality":
                guard let blockHash = signedPayload.blockHash else { throw ExtrinsicError.noGenesisHash }
                try append(try blockHash.hex.decode().asScaleEncoded())
            case "CheckSpecVersion":
                guard let runtimeVersion = signedPayload.runtimeVersion else { throw ExtrinsicError.noRuntimeVersion }
                try append(runtimeVersion.specVersion)
            case "CheckTxVersion":
                guard let runtimeVersion = signedPayload.runtimeVersion else { throw ExtrinsicError.noRuntimeVersion }
                try append(runtimeVersion.txVersion)
            default: break
            }
        }
        
        return self
    }
}
