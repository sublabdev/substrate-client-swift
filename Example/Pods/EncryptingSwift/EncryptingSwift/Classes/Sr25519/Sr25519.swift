import Foundation
import Sr25519

/// Handles SR25519 encryption
class SR25519: SignatureEngine {
    private let data: Data

    /// Creates SR25519 encryption handler
    /// - Parameters:
    ///     - data: The data to encrypt (the seed)
    init(data: Data) {
        self.data = data
    }
    
    /// Loads the private key for SR25519
    /// - Returns: The private key
    func loadPrivateKey() throws -> Data {
        data
    }
    
    /// Generates a public key for SR25519
    /// - Returns: A created public key
    func publicKey() throws -> Data {
        try keyPair().publicKey.raw
    }
    
    // The default signing implementation for SR25519
    /// - Parameters:
    ///     - message: The message that needs to be signed
    /// - Returns: The signature
    func sign(message: Data) throws -> Data {
        try keyPair().sign(message: message).raw
    }
    
    // MARK: - Verification
    /// Verifies the provided message and signature against SR25519
    /// - Parameters:
    ///     - message: The message
    ///     - signature: 64 bytes signature
    /// - Returns: A Bool value indicating whether the verification was successful or not
    func verify(message: Data, signature: Data) throws -> Bool {
        try Sr25519PublicKey(raw: data)
            .verify(message: message, signature: Sr25519Signature(raw: signature))
    }
    
    // Returns a KeyPair object for SR25519
    private func keyPair() throws -> Sr25519.Sr25519KeyPair {
        try Sr25519.Sr25519KeyPair(seed: .init(raw: data))
    }
}

extension Data {
    /// An access point to SR25519 functionality
    public var sr25519: SignatureEngine {
        SR25519(data: self)
    }
}
