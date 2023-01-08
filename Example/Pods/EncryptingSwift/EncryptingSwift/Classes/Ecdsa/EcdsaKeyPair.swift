import Foundation

// ECDSA implementation of KeyPair protocol
struct EcdsaKeyPair: KeyPair {
    public let privateKey: Data
    public let publicKey: Data
    
    public init(privateKey: Data, publicKey: Data) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    // Returns the SignatureEngine for ECDSA
    public func signatureEngine(for data: Data) -> SignatureEngine {
        Ecdsa(data: data)
    }
}

// A factory object for ECDSA key pair
final class EcdsaKeyPairFactory: KeyPairFactory {
    override func load(seed: Data) throws -> KeyPair {
        try EcdsaKeyPair(privateKey: seed, publicKey: seed.ecdsa.publicKey())
    }
}

extension KeyPairFactory {
    /// An access point to ECDSA's `KeyPair`factory
    public static var ecdsa: KeyPairFactory {
        EcdsaKeyPairFactory()
    }
}
