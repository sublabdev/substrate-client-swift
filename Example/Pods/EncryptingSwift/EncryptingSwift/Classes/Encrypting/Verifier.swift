import Foundation

/// An interface for accessing a message and a signature verification functionality
public protocol Verifier {
    /// Verifies the provided message and signature
    /// - Parameters:
    ///     - message: The message
    ///     - signature: 64 bytes signature
    /// - Returns: A Bool value indicating whether the verification was successful or not
    func verify(message: Data, signature: Data) throws -> Bool
}
