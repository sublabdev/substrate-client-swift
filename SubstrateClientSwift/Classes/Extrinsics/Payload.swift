import Foundation

/// An extrinsic's payload object
public protocol Payload {
    var moduleName: String? { get }
    var callName: String? { get }
    
    /// Encodes the payload
    /// - Returns: An encoded `Data` from the payload
    func toData() throws -> Data
}
