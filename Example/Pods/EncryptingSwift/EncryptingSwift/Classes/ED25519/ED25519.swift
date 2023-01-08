import Foundation
import ed25519swift

/// Handles ED25519 encryption
class ED25519: SignatureEngine {
    private let data: Data

    /// Creates ED25519 encryption handler
    /// - Parameters:
    ///     - data: The data to encrypt (the seed)
    init(data: Data) {
        self.data = data
    }
    
    /// Loads a private key for ED25519
    /// - Returns: The private key
    func loadPrivateKey() throws -> Data {
        data
    }
    
    /// Generates a public key for ED25519
    /// - Returns: A created public key
    func publicKey() throws -> Data {
        Data(Ed25519.calcPublicKey(secretKey: data.bytes))
    }
    /// The default signing implementation for ED25519
    /// - Parameters:
    ///     - message: The message that needs to be signed
    /// - Returns: The signature
    func sign(message: Data) throws -> Data {
        Data(Ed25519.sign(message: message.bytes, secretKey: data.bytes))
    }
    
    /// Verifies the provided message and signature against ED25519
    /// - Parameters:
    ///     - message: The message
    ///     - signature: 64 bytes signature
    /// - Returns: A Bool value indicating whether the verification was successful or not
    func verify(message: Data, signature: Data) throws -> Bool {
        Ed25519.verify(signature: signature.bytes, message: message.bytes, publicKey: data.bytes)
    }
}

extension Data {
    /// An access point to ED25519 functionality
    public var ed25519: SignatureEngine {
        ED25519(data: self)
    }
}
