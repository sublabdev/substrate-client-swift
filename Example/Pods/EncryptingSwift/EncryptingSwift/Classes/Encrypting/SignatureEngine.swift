import Foundation

/// The base Signature engine that provides an interface for getting a private key;
/// creating a public key; signing a message; and verifying a signature and a message
public protocol SignatureEngine: Verifier, Signer {
    /// Loads a private key
    /// - Returns: The private key
    func loadPrivateKey() throws -> Data
    /// Generates a public key
    /// - Returns: A created public key
    func publicKey() throws -> Data
}
