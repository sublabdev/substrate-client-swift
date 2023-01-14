import Foundation

/// An extrinsic's payload object
public protocol Payload {
    var moduleName: String? { get }
    var callName: String? { get }
    
    func toData() throws -> Data
}
