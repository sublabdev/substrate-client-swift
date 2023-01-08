import Foundation
import HashingSwift

class Extrinsic {
    let signed: Bool
    let version: UInt = 4
    let address: AccountId
    let signature: Data
    let extra: ExtraExtrinsic
    let payload: Data
    
    var hashValue: Int {
        var result = signed.hashValue
        result = 31 * result + version.hashValue
        result = 31 * result + address.hashValue
        result = 31 * result + signature.hashValue
        result = 31 * result + extra.hashValue
        result = 31 * result + payload.hashValue
        
        return result
    }
    
    init(
        signed: Bool = false,
        address: AccountId,
        signature: Data,
        extra: ExtraExtrinsic,
        payload: Data
    ) {
        self.signed = signed
        self.address = address
        self.signature = signature
        self.extra = extra
        self.payload = payload
    }
    
    func equals(to other: AnyObject) -> Bool {
        if other === self {
            return true
        }
        
        guard let otherExtrinsic = other as? Extrinsic else {
            return false
        }
        
        return self == otherExtrinsic
    }
}

extension Extrinsic: Equatable {
    static func ==(lhs: Extrinsic, rhs: Extrinsic) -> Bool {
        if lhs.signed != rhs.signed {
            return false
        } else if lhs.version != rhs.version {
            return false
        } else if lhs.address != rhs.address {
            return false
        } else if lhs.signature != rhs.signature {
            return false
        } else if lhs.extra != rhs.extra {
            return false
        } else if lhs.payload != rhs.payload {
            return false
        }
        
        return true
    }
}
