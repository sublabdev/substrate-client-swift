import Foundation

/// A factory for creating a `KeyPair` object
open class KeyPairFactory {
    /// Loads seed to create a `KeyPair`.
    /// > NOTE: The method must be implemented, otherwise a fatal error will be thrown
    /// - Parameters:
    ///     - seed: The seed data which is used to generate a `KeyPair` object
    /// - Returns: `KeyPair` object with private and public keys as well as with an interface that provides a signature engine, message signing and signature (and message) verification interfaces.
    open func load(seed: Data) throws -> KeyPair {
        fatalError("Not implemented")
    }
}

/// An interface that holds the private and public key-pair;
/// and also effectively hides the specifics about which `SignatureEngine` is used
public protocol KeyPair: Signer, Verifier {
    /// The private key
    var privateKey: Data { get }
    /// The public key
    var publicKey: Data { get }
    /// Signature engine used
    /// - Parameters:
    ///     - data: The data for which `SignatureEngine` should be returned
    /// - Returns: The `SignatureEngine` for Data
    func signatureEngine(for data: Data) -> SignatureEngine
}

extension KeyPair {
    /// The default signing implementation
    /// - Parameters:
    ///     - message: The message that needs to be signed
    /// - Returns: The signature
    public func sign(message: Data) throws -> Data {
        try signatureEngine(for: privateKey).sign(message: message)
    }
    // The default verification implementation
    /// - Parameters:
    ///     - message: The message
    ///     - signature: 64 bytes signature
    /// - Returns: A Bool value indicating whether the verification was successful or not
    public func verify(message: Data, signature: Data) throws -> Bool {
        try signatureEngine(for: publicKey).verify(message: message, signature: signature)
    }
}
