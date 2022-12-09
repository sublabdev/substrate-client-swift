import Foundation
import CommonSwift

/// Account information
struct Account: Codable {
    let nonce: UInt32
    let consumers: UInt32
    let providers: UInt32
    let sufficients: UInt32
    let data: AccountData
    
    struct AccountData: Codable {
        let free: UInt128
        let reserved: UInt128
        let miscFrozen: UInt128
        let feeFrozen: UInt128
    }
}
