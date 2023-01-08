import Foundation

/// And interface for accessing the message signing functionality
public protocol Signer {
    /// The default signing interface
    /// - Parameters:
    ///     - message: The message that needs to be signed
    /// - Returns: The signature
    func sign(message: Data) throws -> Data
}
