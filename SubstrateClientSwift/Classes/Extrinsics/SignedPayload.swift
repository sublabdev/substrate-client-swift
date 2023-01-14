import EncryptingSwift
import Foundation
import HashingSwift
import ScaleCodecSwift

final class SignedPayload<T: Codable>: Payload {
    fileprivate let runtimeMetadata: RuntimeMetadata
    private weak var codec: ScaleCoder?
    private let payload: UnsignedPayload<T>
    fileprivate let runtimeVersion: RuntimeVersion
    fileprivate let genesisHash: String
    fileprivate let era: Era
    fileprivate let blockHash: String
    fileprivate let accountId: AccountId
    fileprivate let nonce: Index
    fileprivate let tip: Balance
    fileprivate let signatureEngine: SignatureEngine
    
    var moduleName: String { payload.moduleName }
    var callName: String { payload.callName }
    
    init(
        runtimeMetadata: RuntimeMetadata,
        codec: ScaleCoder?,
        payload: UnsignedPayload<T>,
        runtimeVersion: RuntimeVersion,
        genesisHash: String,
        era: Era = .immortal,
        blockHash: String? = nil,
        accountId: AccountId,
        nonce: Index,
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
    func toData() throws -> Data? {
        guard let payloadData = try payload.toData()?.asScaleEncoded() else { return nil }
        return try codec?.transaction()
            .append(0b10000000 + runtimeMetadata.extrinsic.version)
            .appendAccountId(from: self)
            .appendSignature(from: self)
            .appendExtra(from: self)
            .append(payloadData)
            .commit()
    }
}

// MARK: - Signing

extension SignedPayload {
    private func signingPayload() throws -> Data? {
        try codec?.transaction()
            .appendUnsignedPayload(payload)
            .appendExtra(from: self)
            .appendAdditional(from: self)
            .commit()
    }
    
    func sign() throws -> Data? {
        guard var signingPayload = try signingPayload() else { return nil }
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
        let addressTypeDef = try signedPayload.runtimeMetadata.findSignatureTypeDef(name: "Address")
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
        let signatureTypeDef = try signedPayload.runtimeMetadata.findSignatureTypeDef(name: "Signature")
        switch signatureTypeDef {
        case .variant(let runtimeTypeDefVariant):
            let signatureVariants = runtimeTypeDefVariant.variants
            guard let signatureTypeIndex = signatureVariants.first(where: { $0.name.lowercased() == signedPayload.signatureEngine.name.lowercased() })?.index else {
                throw ExtrinsicError.lookupFailure
            }
            
            try append(signatureTypeIndex)
            // Ignore size, inject directly
            guard let signature = try signedPayload.sign() else { throw ExtrinsicError.signingFailure }
            try append(signature.asScaleEncoded())
        default:
            throw ExtrinsicError.lookupFailure
        }
        
        return self
    }
}

// MARK: - `Extra` serialization

extension ScaleCodecTransaction {
    fileprivate func appendExtra<T: Codable>(from signedPayload: SignedPayload<T>) throws -> Self {
        for ext in signedPayload.runtimeMetadata.extrinsic.signedExtensions {
            switch ext.identifier {
            case "CheckMortality": try append(signedPayload.era)
            case "CheckNonce": try append(signedPayload.nonce.value)
            case "ChargeTransactionPayment": try append(signedPayload.tip.value)
            default: break
            }
        }
        
        return self
    }
}

// MARK: - `Additional` serialization

extension ScaleCodecTransaction {
    fileprivate func appendAdditional<T: Codable>(from signedPayload: SignedPayload<T>) throws -> Self {
        for ext in signedPayload.runtimeMetadata.extrinsic.signedExtensions {
            switch ext.identifier {
            case "CheckGenesis":
                try append(try signedPayload.genesisHash.hex.decode().asScaleEncoded())
            case "CheckMortality":
                try append(try signedPayload.blockHash.hex.decode().asScaleEncoded())
            case "CheckSpecVersion":
                try append(signedPayload.runtimeVersion.specVersion)
            case "CheckTxVersion":
                try append(signedPayload.runtimeVersion.txVersion)
            default: break
            }
        }
        
        return self
    }
}
