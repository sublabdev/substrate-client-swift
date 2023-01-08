import Foundation

// ED25519 implementation of KeyPair protocol
struct ED25519KeyPair: KeyPair {
    public let privateKey: Data
    public let publicKey: Data
    
    public init(privateKey: Data, publicKey: Data) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    // Returns the SignatureEngine for ED25519
    public func signatureEngine(for data: Data) -> SignatureEngine {
        ED25519(data: data)
    }
}

// A factory object for ED25519 key pair
final class ED25519KeyPairFactory: KeyPairFactory {
    override func load(seed: Data) throws -> KeyPair {
        try ED25519KeyPair(privateKey: seed, publicKey: seed.ed25519.publicKey())
    }
}

extension KeyPairFactory {
    /// An access point to ED25519's `KeyPair`factory
    public static var ed25519: KeyPairFactory {
        ED25519KeyPairFactory()
    }
}
