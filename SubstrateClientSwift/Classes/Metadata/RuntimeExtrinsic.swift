import Foundation
import BigInt

/// Runtime extrinsic. Contains its type, version and an array of signed extensions
public class RuntimeExtrinsic: Codable {
    let type: BigUInt
    let version: UInt8
    let signedExtensions: [SignedExtension]
    
    init(type: BigUInt, version: UInt8, signedExtensions: [SignedExtension]) {
        self.type = type
        self.version = version
        self.signedExtensions = signedExtensions
    }
    
    class SignedExtension: Codable {
        let identifier: String
        let type: BigUInt
        let additionalSigned: BigUInt
        
        init(identifier: String, type: BigUInt, additionalSigned: BigUInt) {
            self.identifier = identifier
            self.type = type
            self.additionalSigned = additionalSigned
        }
    }
}
