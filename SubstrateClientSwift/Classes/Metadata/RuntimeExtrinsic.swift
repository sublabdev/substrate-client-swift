import Foundation
import BigInt

/// Runtime extrinsic. Contains its type, version and an array of signed extensions
public class RuntimeExtrinsic: Codable {
    public let type: BigUInt
    public let version: UInt8
    public let signedExtensions: [SignedExtension]
    
    public init(type: BigUInt, version: UInt8, signedExtensions: [SignedExtension]) {
        self.type = type
        self.version = version
        self.signedExtensions = signedExtensions
    }
    
    public class SignedExtension: Codable {
        public let identifier: String
        public let type: BigUInt
        public let additionalSigned: BigUInt
        
        public init(identifier: String, type: BigUInt, additionalSigned: BigUInt) {
            self.identifier = identifier
            self.type = type
            self.additionalSigned = additionalSigned
        }
    }
}
